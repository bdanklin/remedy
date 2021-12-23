defmodule Remedy.API do
  @moduledoc """
  Standard interface for the Discord API.

  The majority of the functions within this module are pulled directly from the Discord API. Some custom implementations are included.

  Some functions are useless in the scope of a bot and are intentionally omitted.

  ## Ratelimits

  Discord imposes rate limits in various capacities. The functions in this module will respect those rate limits where possible. In certain circumstances, discord will impose hidden rate limits to avoid abuse, which you can still hit.

  ## Bang!

  While intentionally undocumented to reduce clutter, all functions can be banged to return or raise.

  ## Return Values

  Return values have a number of forms due to the wide range of returns from Discord. Generally they take one of the following forms.

  - `:ok`
  Returned when discord indicates an empty 204 response. Which indicates a request executed successfully. Usually returns for operations such as deleting a channel.

  - `{:ok, body | [body]}`
  Returned when the request has created or changed one or more objects.

  - `{:error, {403, 10004, "Unknown Guild"}}`
  Returned when a request fails.

  ## Audit Log Reason

  Many endpoints accept the `X-Audit-Log-Reason` header to provide a reason for the action. This is a string that is displayed in the audit log, limited to 512 characters.

  Due to Discords API documentation being sketchy, this header is not always accurately documented where it is accepted.

  """
  import Ecto.Changeset
  alias Ecto.Changeset
  alias Remedy.Snowflake

  import Remedy.TimeHelpers,
    only: [is_snowflake: 1],
    warn: false

  alias Remedy.Schema.{
    App,
    AuditLog,
    Channel,
    Embed,
    Guild,
    Integration,
    Invite,
    Member,
    Message,
    Permission,
    Role,
    Sticker,
    Thread,
    User
  }

  alias Remedy.API.{
    Rest,
    RestRequest,
    RestResponse
  }

  use Unsafe.Generator,
    handler: :unwrap,
    docs: false

  @type code :: integer()
  @type opts :: keyword() | nil
  @type params :: keyword() | nil
  @type error :: any()
  @type limit :: integer()
  @type locator :: any
  @type snowflake :: Remedy.Snowflake.t()
  @type reason :: String.t() | nil
  @type token :: String.t()

  ### Discord API Proper
  ###
  ### Functions are ordered by their occurence within the discord API
  ### documentation to make it easier to track and insert new functions.
  ### They are automatically reordered for the documentation
  ###
  ### Functions are renamed when appropriate.
  ###
  ### When using remedy_exdoc, the `@doc route:` attribute can be set and
  ### displayed within the functions documentation
  ###
  ### Permissions / Events / Options / Examples / Helpers
  ###
  #################################################################

  #################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░░█████╗░░░█████╗░░██╗░░░██╗░████████╗░██╗░░██╗░██████╗░░ ###
  ### ░██╔══██╗░██╔══██╗░██║░░░██║░╚══██╔══╝░██║░░██║░╚════██╗░ ###
  ### ░██║░░██║░███████║░██║░░░██║░░░░██║░░░░███████║░░░███╔═╝░ ###
  ### ░██║░░██║░██╔══██║░██║░░░██║░░░░██║░░░░██╔══██║░██╔══╝░░░ ###
  ### ░╚█████╔╝░██║░░██║░╚██████╔╝░░░░██║░░░░██║░░██║░███████╗░ ###
  ### ░░╚════╝░░╚═╝░░╚═╝░░╚═════╝░░░░░╚═╝░░░░╚═╝░░╚═╝░╚══════╝░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  #################################################################

  @doc """
  Gets the bot's application info.

  ## Examples

      iex> Remedy.API.get_application()
      {:ok, %Remedy.Schema.App{}}

  """
  @doc since: "0.6.8"
  @doc method: "get"
  @doc route: "/oauth2/applications/@me"
  @unsafe {:get_application, []}
  @spec get_application() :: {:error, any} | {:ok, map}
  def get_application do
    {:get, "/oauth2/applications/@me", nil, nil, nil}
    |> request()
    |> shape(App)
  end

  ## Only used for OAuth. Not used for Bots.
  @doc false
  @doc since: "0.6.8"
  @doc method: "get"
  @doc route: "/oauth2/@me"
  @spec get_current_authorization_information() :: {:error, reason} | {:ok, map()}
  @unsafe {:get_current_authorization_information, []}
  def get_current_authorization_information do
    {:get, "/oauth2/@me", nil, nil, nil}
    |> request()
  end

  ####################################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░░█████╗░░██╗░░░██╗░██████╗░░██╗░████████╗░░░░░░██╗░░░░░░░█████╗░░░██████╗░░ ###
  ### ░██╔══██╗░██║░░░██║░██╔══██╗░██║░╚══██╔══╝░░░░░░██║░░░░░░██╔══██╗░██╔════╝░░ ###
  ### ░███████║░██║░░░██║░██║░░██║░██║░░░░██║░░░░░░░░░██║░░░░░░██║░░██║░██║░░██╗░░ ###
  ### ░██╔══██║░██║░░░██║░██║░░██║░██║░░░░██║░░░░░░░░░██║░░░░░░██║░░██║░██║░░╚██╗░ ###
  ### ░██║░░██║░╚██████╔╝░██████╔╝░██║░░░░██║░░░░░░░░░███████╗░╚█████╔╝░╚██████╔╝░ ###
  ### ░╚═╝░░╚═╝░░╚═════╝░░╚═════╝░░╚═╝░░░░╚═╝░░░░░░░░░╚══════╝░░╚════╝░░░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ####################################################################################

  @doc """
  Get the audit log for the given guild.

  ## Options

  - `:action_type`  - `:integer` - [Audit Log Action Types](https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events)
  - `:before`  - `Snowflake`
  - `:user_id`  - `Snowflake`
  - `:limit`  - `:integer, default: 50, min: 1, max: 100`

  ## Examples

      iex> Remedy.API.get_audit_log(872417560094732328)
      {:ok, %Remedy.Schema.AuditLog{}}

      iex> Remedy.API.get_audit_log(872417560094732328, limit: 3, user_id: 883307747305725972)
      {:ok, %Remedy.Schema.AuditLog{}}

      iex> Remedy.API.get_audit_log(123)
      {:error, {403, 10004, "Unknown Guild"}}

  """
  @doc since: "0.6.0"
  @doc method: :get
  @doc permissions: [:GET_AUDIT_LOG, :AUDIT_LOG]
  @doc events: :GUILD_UPDATE
  @doc audit_log: true
  @doc route: "/guilds/:guild_id/audit-logs"
  @unsafe {:get_audit_log, [:guild_id, :opts]}
  @spec get_audit_log(snowflake | Guild.t(), opts) :: {:error, any} | {:ok, AuditLog.t()}
  def get_audit_log(guild_id, opts \\ [])
  def get_audit_log(%Guild{id: id}, opts), do: get_audit_log(id, opts)

  def get_audit_log(guild_id, opts) when is_snowflake(guild_id) do
    data = %{limit: 50}
    types = %{action_type: :integer, before: Snowflake, limit: :integer}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    params =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:limit, greater_than: 1, less_than_or_equal_to: 100)

    {:get, "/guilds/#{guild_id}/audit-logs", params, nil, nil}
    |> request()
    |> add_guild_id_to_audit_log(guild_id)
    |> shape(AuditLog)
  end

  defp add_guild_id_to_audit_log({:error, _reason} = error, _guild_id), do: error
  defp add_guild_id_to_audit_log({:ok, response}, guild_id), do: {:ok, Map.put_new(response, :guild_id, guild_id)}

  ###################################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░░█████╗░░██╗░░██╗░░█████╗░░███╗░░██╗░███╗░░██╗░███████╗░██╗░░░░░░░██████╗░ ###
  ### ░██╔══██╗░██║░░██║░██╔══██╗░████╗░██║░████╗░██║░██╔════╝░██║░░░░░░██╔════╝░ ###
  ### ░██║░░╚═╝░███████║░███████║░██╔██╗██║░██╔██╗██║░█████╗░░░██║░░░░░░╚█████╗░░ ###
  ### ░██║░░██╗░██╔══██║░██╔══██║░██║╚████║░██║╚████║░██╔══╝░░░██║░░░░░░░╚═══██╗░ ###
  ### ░╚█████╔╝░██║░░██║░██║░░██║░██║░╚███║░██║░╚███║░███████╗░███████╗░██████╔╝░ ###
  ### ░░╚════╝░░╚═╝░░╚═╝░╚═╝░░╚═╝░╚═╝░░╚══╝░╚═╝░░╚══╝░╚══════╝░╚══════╝░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ###################################################################################

  @doc """
  Get a channel.

  ## Examples

      iex> Remedy.API.get_channel(872417560094732331)
      {:ok, %Remedy.Schema.Channel.t{}}

  """

  @doc since: "0.6.0"
  @unsafe {:get_channel, [:channel_id]}
  @spec get_channel(snowflake | Channel.t() | Message.t()) :: {:error, any} | {:ok, Channel.t()}
  def get_channel(channel_id)

  def get_channel(channel_id) when is_snowflake(channel_id) do
    {:get, "/channels/#{channel_id}", nil, nil, nil}
    |> request()
    |> shape(Channel)
  end

  def get_channel(%Channel{id: channel_id}) do
    get_channel(channel_id)
  end

  def get_channel(%Message{channel_id: channel_id}) do
    get_channel(channel_id)
  end

  @doc """
  Modifies a channel's settings.

  Instead of a channel_id, you can also pass a fully formed channel object with the changes included.

  ## Permissions

  - `:MANAGE_CHANNEL`

  ## Events

  - `:CHANNEL_UPDATE`.

  ## Options

  - `:name`  - `:string, min: 2, max: 100`
  - `:position`  - `:integer` - Not contiguous, will be ordered by `:id` if duplicates exist.
  - `:topic`  `:string, min: 0, max: 1024`
  - `:nsfw`  `:boolean, default: false`
  - `:bitrate`  - `:integer, min: 8000, max: 128000`
  - `:user_limit`  - `:integer, min: 1, max: 99, unlimited: 0`
  - `:permission_overwrites`  - `{:array, %Overwrite{}}`
  - `:parent_id`  - category to place the channel under.
  -

  ## Examples

      iex> Remedy.API.modify_channel(41771983423143933, name: "elixir-remedy", topic: "remedy discussion")
      {:ok, %Remedy.Schema.Channel{id: 41771983423143933, name: "elixir-remedy", topic: "remedy discussion"}}


  """

  @doc since: "0.6.0"
  @unsafe {:modify_channel, [:channel_id, :opts]}
  @spec modify_channel(snowflake, opts) :: {:error, any} | {:ok, Channel.t()}
  def modify_channel(channel_id, opts \\ [])

  def modify_channel(channel_id, opts) when is_snowflake(channel_id) and is_list(opts) do
    data = %{}

    types = %{
      name: :string,
      position: :integer,
      topic: :string,
      nsfw: :boolean,
      bitrate: :integer,
      user_limit: :integer,
      permission_overwrites: {:array, :map},
      parent_id: Snowflake
    }

    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_length(:name, min: 2, max: 100)
      |> validate_length(:topic, min: 2, max: 100)
      |> validate_number(:bitrate, min: 8000, max: 128_000)
      |> validate_number(:user_limit, min: 0, max: 99)

    {:patch, "/channels/#{channel_id}", nil, opts[:reason], body}
    |> request()
    |> shape(Channel)
  end

  @doc since: "0.6.8"
  @unsafe {:modify_channel, [:channel]}
  @spec modify_channel(Channel.t(), reason) :: {:error, any} | {:ok, Channel.t()}

  def modify_channel(%Channel{id: id} = channel, []) do
    opts = filter_schema_into_opts(channel)

    modify_channel(id, opts)
  end

  def modify_channel(%Channel{id: id} = channel, reason) when is_binary(reason) do
    opts =
      channel
      |> filter_schema_into_opts()
      |> Keyword.put_new(:reason, reason)

    modify_channel(id, opts)
  end

  @doc """
  Deletes a channel.

  An optional `reason` can be provided for the guild audit log.

  ## Permissions

  - `:MANAGE_CHANNELS`

  ## Events

  - `:CHANNEL_DELETE`

  ## Options

  - `:reason` - `:string, min: 2, max: 512`

  ## Examples

    iex> Remedy.API.delete_channel(421533712753360896)
    {:ok, %Remedy.Schema.Channel{id: 421533712753360896}}

    iex> Remedy.API.delete_channel(123)
    {:error, reason}

  """

  @doc since: "0.6.0"
  @spec delete_channel(snowflake, opts) :: {:error, any} | {:ok, map}
  @unsafe {:delete_channel, [:channel_id, :opts]}
  def delete_channel(channel, opts \\ [])

  def delete_channel(channel_id, opts) when is_snowflake(channel_id) do
    {:delete, "/channels/#{channel_id}", nil, opts[:reason], nil}
    |> request()
    |> shape(Channel)
  end

  def delete_channel(%Channel{id: channel_id}, []) do
    delete_channel(channel_id, [])
  end

  def delete_channel(%Channel{id: channel_id}, reason) when is_binary(reason) do
    opts = Keyword.put_new([], :reason, reason)

    delete_channel(channel_id, opts)
  end

  @doc """
  Retrieves a channel's messages.

  ## Permissions

  - `:VIEW_CHANNEL`
  - `:READ_MESSAGE_HISTORY`

  ## Options

  - `:before`  - `Snowflake` - Retrieve messages before this message.
  - `:after`  - `Snowflake` - Retrieve messages after this message.
  - `:around`  - `Snowflake` - Retrieve messages around this message.
  - `:limit`  - `:integer, min: 1, max: 100` - The maximum number of messages to retrieve.

  > Only one of `:before`, `:after`, or `:around` may be specified.


  ## Examples

      iex> Remedy.API.list_messages(872417560094732331, [{:before, 882781809908256789}, {:limit, 1}])
      {:ok, [%Message{id: 882681855315423292}]}


  ## Helpers

  - `Remedy.API.list_messages_before/3`
  - `Remedy.API.list_messages_after/3`
  - `Remedy.API.list_messages_around/3`

  """
  @doc since: "0.6.0"
  @unsafe {:list_messages, [:channel_id, :params]}
  @spec list_messages(snowflake, opts) :: {:error, any} | {:ok, [Remedy.Schema.Channel.t()]}
  def list_messages(channel_id, opts \\ []) do
    data = %{limit: 50}
    types = %{before: Snowflake, after: Snowflake, around: Snowflake, limit: :integer}
    keys = Map.keys(types)

    params =
      cond do
        Keyword.has_key?(opts, :before) -> Keyword.take(opts, [:before, :limit])
        Keyword.has_key?(opts, :after) -> Keyword.take(opts, [:after, :limit])
        Keyword.has_key?(opts, :around) -> Keyword.take(opts, [:around, :limit])
        true -> Keyword.take(opts, [:limit])
      end
      |> Enum.into(%{})

    params =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:limit, min: 1, max: 100)

    {:get, "/channels/#{channel_id}/messages", params, nil, nil}
    |> request()
  end

  @doc """
  List messages before a given message.

  ## Permissions

  - `VIEW_CHANNEL`
  - `READ_MESSAGE_HISTORY`


  ## Examples

      iex> Remedy.API.list_messages_before(%{channel_id: 872417560094732331, id: 882781809908256789}, limit: 1)
      {:ok, [%Message{id: 882681855315423292}]}

  """
  @doc since: "0.6.0"
  @unsafe {:list_messages_before, [:message, :limit]}
  @spec list_messages_before(Message.t(), limit) :: {:error, any} | {:ok, list}
  def list_messages_before(%{id: message_id, channel_id: channel_id} = message, limit \\ 50)
      when is_map(message) do
    list_messages(channel_id, [{:before, message_id}, {:limit, limit}])
  end

  @doc """
  List messages after a given message.

  ## Permissions

  - `:VIEW_CHANNEL`
  - `:READ_MESSAGE_HISTORY`

  ## Examples

      iex> Remedy.API.list_messages_after(%{channel_id: 872417560094732331, id: 882781809908256789}, limit: 1)
      {:ok, [%Message{id: 882681855315423292}]}


  """
  @doc since: "0.6.0"
  @unsafe {:list_messages_after, [:message, :limit]}
  @spec list_messages_after(Message.t(), limit) :: {:error, any} | {:ok, list}
  def list_messages_after(message, limit \\ 50)

  def list_messages_after(%Message{id: message_id, channel_id: channel_id} = message, limit)
      when is_struct(message, Message) do
    list_messages(channel_id, [{:after, message_id}, {:limit, limit}])
  end

  @doc """
  List messages around a given message.

  ## Permissions

  - `VIEW_CHANNEL`
  - `READ_MESSAGE_HISTORY`

  ## Examples

      iex> Remedy.API.list_messages_around(%{channel_id: 872417560094732331, id: 882781809908256789}, limit: 1)
      {:ok, [%Message{id: 882681855315423292}]}

  """
  @doc since: "0.6.0"
  @unsafe {:list_messages_around, [:message, :limit]}
  @spec list_messages_around(Message.t(), limit) :: {:error, any} | {:ok, list}
  def list_messages_around(message, limit \\ 50)

  def list_messages_around(%Message{id: message_id, channel_id: channel_id} = message, limit)
      when is_struct(message, Message) do
    list_messages(channel_id, [{:around, message_id}, {:limit, limit}])
  end

  @doc """
  Retrieves a message from a channel.

  ## Permissions

  - 'VIEW_CHANNEL'
  - 'READ_MESSAGE_HISTORY'

  ## Examples

      iex> Remedy.API.get_message(872417560094732331, 884355195277025321)
      {:ok, %Remedy.Schema.Message{}}

  """
  @doc since: "0.6.0"
  @unsafe {:get_message, [:channel_id, :message_id]}
  @spec get_message(snowflake, snowflake) :: {:error, any} | {:ok, Message.t()}
  def get_message(channel_id, message_id) do
    {:get, "/channels/#{channel_id}/messages/#{message_id}", nil, nil, nil}
    |> request()
    |> shape(Message)
  end

  @doc """
  Posts a message to a guild text or DM channel.

  > Discord may strip certain characters from message content, like invalid unicode characters or characters which cause unexpected message formatting. If you are passing user-generated strings into message content, consider sanitizing the data to prevent unexpected behavior and utilizing allowed_mentions to prevent unexpected mentions.

  You may create a message as a reply to another message. To do so, include a `:message_reference` with a `:message_id`. The `:channel_id` and `:guild_id` in the message_reference are optional, but will be validated if provided.

  ## Intents

  - `:VIEW_CHANNEL`
  - `:SEND_MESSAGES`
  - `:SEND_MESSAGES_TTS`

  ## Events

  - `:MESSAGE_CREATE`

  ## Options

  - `:content`  - `:string, max: 2000`
  - `:tts`  - `:boolean`
  - `:embeds`  - {:array, Embed | :map}
  - `:allowed_mentions`  - `AllowedMentions | :map`
  - `:message_reference`  - `MessageReference | :map
  - `:components`  - `{:array, Component | :map}
  - `:sticker_ids`  - `{:array, Snowflake}
  - `:attachments`  - `{:array, Attachment}

  > Note: At least one of the following is required: `:content`, `:file`, `:embed`.

  ### Allowed mentions
  - `:all` (default) - Ping everything as usual
  - `:none` - Nobody will be pinged
  - `:everyone` - Allows to ping @here and @everone
  - `:users` - Allows to ping users
  - `:roles` - Allows to ping roles
  - `{:users, list}` - Allows to ping list of users. Can contain up to 100 ids of users.
  - `{:roles, list}` - Allows to ping list of roles. Can contain up to 100 ids of roles.


  ## Examples

      iex> {:ok, message} = Remedy.API.create_message(872417560094732331, content: "**Doctest Message** ✅")
      ...> message.content
      "**Doctest Message** ✅"

  """
  @doc since: "0.6.0"
  @spec create_message(snowflake, opts | binary | map | Message.t() | Embed.t()) ::
          {:error, any} | {:ok, any}
  @unsafe {:create_message, [:channel_id, :message]}
  def create_message(channel_id, opts \\ [])

  def create_message(channel_id, message) when is_binary(message) do
    create_message(channel_id, %{content: message})
  end

  def create_message(channel_id, embed) when is_struct(embed, Embed) do
    create_message(channel_id, %{embeds: [embed]})
  end

  def create_message(channel_id, opts) do
    data = %{}

    types = %{
      content: :string,
      tts: :boolean,
      embeds: {:array, :map},
      allowed_mentions: AllowedMentions,
      message_reference: MessageReference,
      components: {:array, Component},
      sticker_ids: {:array, Snowflake},
      attachments: {:array, Attachment}
    }

    keys = Map.keys(types)

    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_at_least_one([:content, :embeds, :sticker_ids, :attachments])
      |> validate_length(:content, max: 2000)

    {:post, "/channels/#{channel_id}/messages", nil, opts[:reason], body}
    |> request()
    |> shape(Message)
  end

  @doc """
  Publish a message in a news channel.

  This will propagate a message out to all followers of the channel.

  ## Permissions

  - `:SEND_MESSAGES`
  - `:MANAGE_MESSAGES`

  ## Examples

      iex> Remedy.API.publish_message(message_object)
      {:ok, %Remedy.Schema.Message{}}

  """
  @doc since: "0.6.0"
  @spec publish_message(Message.t()) :: {:error, any} | {:ok, any}
  @unsafe {:publish_message, [:message]}
  def publish_message(%Message{channel_id: channel_id, id: id}),
    do: publish_message(channel_id, id)

  @doc """
  Publish a message in a news channel.

  This will propagate a message out to all followers of the channel. This function accepts a channel ID and message ID instead of a message object.

  ## Permissions

  - `:SEND_MESSAGES`
  - `:MANAGE_MESSAGES`

  ## Examples

      iex> Remedy.API.publish_message(872417560094732331, 884355195277025321)
      {:ok, %Remedy.Schema.Message{}}

  """

  @doc since: "0.6.8"
  @spec publish_message(snowflake, snowflake) :: {:error, any} | {:ok, map}
  @unsafe {:publish_message, [:channel_id, :message_id]}
  def publish_message(channel_id, message_id) do
    {:post, "/channels/#{channel_id}/messages/#{message_id}/crosspost", nil, nil, nil}
    |> request()
    |> shape(Message)
  end

  @doc """
  Creates a reaction for a message.

  ## Permissions

  - `:VIEW_CHANNEL`
  - `:READ_MESSAGE_HISTORY`
  - `:ADD_REACTIONS`

  ## Examples

      iex> Remedy.API.create_reaction(123123123123, 321321321321, %{id: 43819043108, name: "foxbot"})
      :ok

      iex> Remedy.API.create_reaction(123123123123, 321321321321, "\xF0\x9F\x98\x81")
      :ok


  """
  @doc since: "0.6.0"
  @unsafe {:create_reaction, [:channel_id, :message_id, :emoji]}
  @spec create_reaction(snowflake, snowflake, binary | Emoji.t() | map) :: :ok | {:error, reason}
  def create_reaction(channel_id, message_id, emoji) when is_binary(emoji) do
    {:put, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me", nil, nil, nil}
    |> request()
    |> shape()
  end

  def create_reaction(channel_id, message_id, %{name: name, id: id}) do
    create_reaction(channel_id, message_id, "#{name}:#{id}")
  end

  @doc """
  Creates a reaction for a message.

  Takes a message object instead of a channel ID and message ID.

  ## Permissions

  - `:VIEW_CHANNEL`
  - `:READ_MESSAGE_HISTORY`

  ## Events

  - `:MESSAGE_REACTION_ADD`

  ## Examples

      iex> Remedy.API.create_reaction(message_object, %{id: 43819043108, name: "foxbot"})
      :ok

      iex> Remedy.API.create_reaction(message_object, "\xF0\x9F\x98\x81")
      :ok


  """
  @doc since: "0.6.8"
  @unsafe {:create_reaction, [:message, :emoji]}
  @spec create_reaction(Message.t(), binary | Emoji.t() | map) :: :ok | {:error, reason}
  def create_reaction(message, emoji) do
    create_reaction(message.channel_id, message.id, emoji)
  end

  @doc """
  Deletes a reaction the bot has made for the message.

  ## Permissions

  - `VIEW_CHANNEL`
  - `READ_MESSAGE_HISTORY`

  ## Events

  - `:MESSAGE_REACTION_REMOVE`

  ## Examples

      iex> Remedy.API.delete_bot_reaction(channel_id, message_id, 123)
      :ok

  """
  @doc since: "0.6.0"
  @unsafe {:delete_bot_reaction, [:channel_id, :message_id, :emoji]}
  @spec delete_bot_reaction(snowflake, snowflake, term) :: :ok | {:error, reason}
  def delete_bot_reaction(channel_id, message_id, emoji) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Deletes another user's reaction from a message.

  ## Permissions

  - `VIEW_CHANNEL`
  - `READ_MESSAGE_HISTORY`
  - `MANAGE_MESSAGES`

  ## Examples

       iex>

  """
  @doc since: "0.6.0"
  @spec delete_user_reaction(snowflake, snowflake, snowflake, any) :: {:error, any} | {:ok, any}
  @unsafe {:delete_user_reaction, [:channel_id, :message_id, :emoji, :user_id]}
  def delete_user_reaction(channel_id, message_id, emoji, user_id) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/#{user_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Gets all users who reacted with an emoji.

  This endpoint requires the `VIEW_CHANNEL` and `READ_MESSAGE_HISTORY` permissions.

  If successful, returns `{:ok, users}`. Otherwise, returns {:error, reason}.

  See `create_reaction/3` for similar examples.
  """

  @doc since: "0.6.0"
  @unsafe {:list_reactions, [:channel_id, :message_id, :emoji]}
  @spec list_reactions(snowflake, snowflake, any) :: {:ok, [User.t()]}
  def list_reactions(channel_id, message_id, emoji) do
    {:get, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}", nil, nil, nil}
    |> request()
    |> shape(User)
  end

  @doc """
  Deletes all reactions from a message.

  ## Permissions

  - `VIEW_CHANNEL`,
  - `READ_MESSAGE_HISTORY`
  - `MANAGE_MESSAGES`

  ## Events

  - `:MESSAGE_REACTION_REMOVE_ALL`.

  ## Examples

  iex> Remedy.API.delete_reactions(893605899128676443, 912815032755191838)
  :ok

  """
  @doc since: "0.6.0"
  @spec delete_reactions(snowflake, snowflake) :: {:error, reason} | :ok
  @unsafe {:delete_reactions, [:channel_id, :message_id]}
  def delete_reactions(channel_id, message_id) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Deletes all reactions of a given emoji from a message.

  ## Permissions

  - `MANAGE_MESSAGES`

  ## Events

  - `:MESSAGE_REACTION_REMOVE_EMOJI`

  If successful, returns `{:ok}`. Otherwise, returns {:error, reason}.

  See `create_reaction/3` for similar examples.
  """

  @unsafe {:delete_reactions, [:channel_id, :message_id, :emoji]}
  def delete_reactions(channel_id, message_id, emoji) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}", nil, nil, nil}
    |> request()
  end

  @doc """
  Edits a previously sent message in a channel.

  ## Permissions

  - `VIEW_CHANNEL`

  ## Events

  - `:MESSAGE_UPDATE`.

  ## Options

    - `:content` (string) - the message contents (up to 2000 characters)
    - `:embed` (`t:Remedy.Schema.Embed.t/0`) - embedded rich content

  ## Examples

      iex> Remedy.API.modify_message(889614079830925352, 1894013840914098, content: "hello world!")
      :ok

      iex> Remedy.API.modify_message(889614079830925352, 1894013840914098, "hello world!")
      :ok


  """
  @doc since: "0.6.0"
  @unsafe {:modify_message, [:channel_id, :message_id, :opts]}
  @spec modify_message(snowflake, snowflake, opts) :: :ok | {:error, reason}
  def modify_message(channel_id, message_id, opts) do
    data = %{}
    types = %{content: :string, embed: Embed}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/channels/#{channel_id}/messages/#{message_id}", nil, nil, body}
    |> request()
  end

  @doc """
  Deletes a message.

  ## Permissions

  - 'VIEW_CHANNEL'
  - 'MANAGE_MESSAGES'

  ## Events

  - `MESSAGE_DELETE`

  ## Examples

      iex> Remedy.API.delete_message(43189401384091, 43189401384091)

  """
  @unsafe {:delete_message, [:channel_id, :message_id]}
  def delete_message(channel_id, message_id) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}", nil, nil, nil}
    |> request()
  end

  @doc """
  Deletes multiple messages from a channel.

  This can only be used on guild channels.

  ## Permissions

  - `:MANAGE_MESSAGES`

  ## Events

  - `:MESSAGE_DELETE_BULK`

  ## Options

  - `:messages`  - `{:array, Snowflake}` - the messages to delete
  - `:reason`  - `:string` - the reason for deleting the messages


  """
  @doc since: "0.6.0"
  @unsafe {:delete_messages, [:channel_id, :opts]}
  @spec delete_messages(snowflake, opts) :: {:error, reason} | :ok
  def delete_messages(channel_id, opts \\ [])

  def delete_messages(channel_id, opts) when is_snowflake(channel_id) do
    data = %{}
    reason = to_string(opts[:reason])
    types = %{messages: {:array, Snowflake}}
    keys = Map.keys(types)

    messages =
      opts[:messages]
      |> MapSet.new()
      |> MapSet.to_list()
      |> Enum.reject(&less_than_two_weeks_old?(&1))

    params = %{messages: messages}

    body =
      {data, types}
      |> cast(params, keys)

    {:post, "/channels/#{channel_id}/messages/bulk-delete", nil, reason, body}
    |> request()
  end

  defp less_than_two_weeks_old?(snowflake) do
    this_snowflake = Remedy.TimeHelpers.to_unixtime(snowflake)
    two_weeks = 1000 * 60 * 60 * 24 * 14
    two_weeks_ago = System.os_time(:millisecond) - two_weeks

    this_snowflake < two_weeks_ago
  end

  @doc """
  Edit the permission overwrites for a user or role.

  ## Permissions

  - `:MANAGE_ROLES`

    ## Events

  - `:CHANNEL_PERMISSION_UPDATE`

  ## Options

    - `:type`  - `:integer, role: 0, member: 1`
    - `:allow`  - `:integer | Permission`
    - `:deny`  - `:integer | Permission`
    - `:reason`  - `:string` - the reason for editing the permission

  > note: If `:allow`, or `:deny` are not explicitly set they will be set to 0.

  ## Examples

      iex> Remedy.API.edit_permissions(893605899128676443, 893605899128676443, type: :role, allow: :read_messages)


  """
  @doc since: "0.6.0"
  @unsafe {:modify_channel_permissions, [:channel_id, :overwrite_id]}
  @spec modify_channel_permissions(snowflake, snowflake, opts) :: :ok | {:error, reason}
  def modify_channel_permissions(channel_id, overwrite_id, opts) do
    data = %{allow: 0, deny: 0}
    types = %{type: :integer, allow: Permission, deny: Permission}
    keys = Map.keys(types)

    params =
      Enum.into(opts, %{})
      |> Map.put(:type, parse_role_type(opts[:type]))

    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)

    {:put, "/channels/#{channel_id}/permissions/#{overwrite_id}", nil, reason, body}
    |> request()
    |> shape()
  end

  defp parse_role_type(nil), do: nil
  defp parse_role_type(:role), do: 0
  defp parse_role_type(:member), do: 1
  defp parse_role_type(type) when type in [0, 1], do: type

  @doc """
  Gets a list of invites for a channel.

  ## Permissions

  - ':VIEW_CHANNEL'
  - ':MANAGE_CHANNELS'

  ## Examples

      iex> Remedy.API.list_channel_invites(43189401384091)
      {:ok, [%Remedy.Schema.Invite{}]}

  """
  @doc since: "0.6.0"
  @unsafe {:list_channel_invites, [:channel_id]}
  @spec list_channel_invites(snowflake) :: {:ok, [Invite.t()]} | {:error, reason}
  def list_channel_invites(channel_id) do
    {:get, "/channels/#{channel_id}/invites", nil, nil, nil}
    |> request()
    |> shape(Invite)
  end

  @doc """
  Creates an invite for a guild channel.

  ## Permissions

  - `:CREATE_INSTANT_INVITE`

  ## Options

    - `:max_age`  -  `:integer, min: 0, max: 604800, default: 86400` - duration of invite in seconds before expiry, or 0 for never.
    - `:max_uses`  -  `:integer, min: 0, max: 100, default: 0` - number of times the invite can be used, or 0 for unlimited.
    - `:temporary`  - `:boolean, default: false` - Whether the invite should grant temporary membership.
    - `:unique`  - `:boolean, default: false` - 	if true, don't try to reuse a similar invite (useful for creating many unique one time use invites)
    - `:target_type`  - `:integer` - 	the type of target for this voice channel invite.
      - `stream: 1, embedded: 2`
    - `:target_user_id`  - `Snowflake` - 	the id of the user whose stream to display for this invite, required if target_type is 1, the user must be streaming in the channel
    - `:target_application_id`  - `Snowflake`  - 	the id of the embedded application to open for this invite, required if target_type is 2, the application must have the EMBEDDED flag
    - `:reason`

  ## Target Type

  If the target type is set, the target_user_id or target_application_id fields must be set respective to the target type.


  ## Examples

      iex> Remedy.API.create_channel_invite(41771983423143933)
      {:ok, Remedy.Schema.Invite{}}

      iex> Remedy.API.create_channel_invite(41771983423143933, max_uses: 20)
      {:ok, %Remedy.Schema.Invite{}}

  """
  @doc since: "0.6.0"
  @unsafe {:create_channel_invite, [:channel_id]}
  @spec create_invite(snowflake, opts) :: {:ok, Invite.t()} | {:error, reason}
  def create_invite(channel_id, opts) do
    data = %{max_age: 86400, max_uses: 0, temporary: false, unique: false}

    types = %{
      max_age: :integer,
      max_uses: :integer,
      temporary: :boolean,
      unique: :boolean,
      target_type: :integer,
      target_user_id: Snowflake,
      target_application_id: Snowflake
    }

    params = Enum.into(opts, %{})
    keys = Map.keys(types)

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:max_age, greater_than_or_equal_to: 0, less_than_or_equal_to: 604_800)
      |> validate_number(:max_uses, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
      |> validate_inclusion(:target_type, [1, 2])

    {:post, "/channels/#{channel_id}/invites", nil, nil, body}
    |> request()
    |> shape(Invite)
  end

  @doc """
  Delete a channel permission overwrite for a user or role.

  ## Permissions

  - `:MANAGE_ROLES`

  ## Options

  - `:reason`

  ## Examples

      iex> Remedy.API.delete_channel_permission(41771983423143933, 41771983423143933)
      :ok

  """
  @doc since: "0.6.0"
  @spec delete_channel_permission(snowflake, snowflake, opts) :: {:error, reason} | :ok
  @unsafe {:delete_channel_permissions, [:channel_id, :overwrite_id, :reason]}
  def delete_channel_permission(channel_id, overwrite_id, opts) do
    reason = opts[:reason]

    {:delete, "/channels/#{channel_id}/permissions/#{overwrite_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  @doc """
  Follow a news channel to send messages to a target channel.

  ## Permissions

  - `:MANAGE_WEBHOOKS`

  ## Examples

  > note: channel_id is the news channel. webhook_channel_id is the target channel.

      iex> Remedy.API.follow_news_channel(41771983423143933, 41771983423143933)
      {:ok, %{}}

  """
  @doc since: "0.6.0"
  @unsafe {:follow_news_channel, 1}
  @spec follow_news_channel(snowflake, snowflake) :: {:ok, Channel.t()} | {:error, reason}
  def follow_news_channel(channel_id, webhook_channel_id) do
    body = %{webhook_channel_id: webhook_channel_id}

    {:post, "/channels/#{channel_id}/followers", nil, nil, body}
    |> request()
    |> case do
      {:ok, _body} -> :ok
      error -> error
    end
  end

  @doc """
  Triggers the typing indicator.

  ## Events

  - `:TYPING_START`

  ## Examples

      iex> Remedy.API.start_typing(891925736120791080)
      :ok

      iex> Remedy.API.start_typing(bad_channel_id)
      {:error, {404, 10003, "Unknown Channel"}}

  """
  @doc since: "0.6.8"
  @unsafe {:start_typing, [:channel_id]}
  @spec start_typing(snowflake) :: :ok | {:error, reason}
  def start_typing(channel_id) do
    {:post, "/channels/#{channel_id}/typing", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Retrieves all pinned messages from a channel.

  ## Permissions

  - 'VIEW_CHANNEL'
  - 'READ_MESSAGE_HISTORY'

  ## Examples

      iex> Remedy.API.get_pinned_messages(43189401384091)
      {ok, %Message{}}

  """
  @doc since: "0.6.0"
  @unsafe {:list_pinned_messages, [:channel_id]}
  def list_pinned_messages(channel_id) do
    {:get, "/channels/#{channel_id}/pins", nil, nil, nil}
    |> request()
    |> shape(Message)
  end

  @doc """
  Pins a message in a channel.

  The max pinned messages for a channel is 50

  ## Permissions

  - 'MANAGE_MESSAGES'

  ## Events

  - `:MESSAGE_UPDATE`
  - `:CHANNEL_PINS_UPDATE`

  ## Options

  - `:reason`

  ## Examples

      iex> Remedy.API.pin_message(43189401384091, 18743893102394)
      :ok

  """
  @doc since: "0.6.0"
  @spec pin_message(snowflake, snowflake, opts) :: :ok | {:error, any}
  @unsafe {:pin_message, [:channel_id, :message_id]}
  def pin_message(channel_id, message_id, opts \\ [])

  def pin_message(channel_id, message_id, opts)
      when is_snowflake(channel_id) and is_snowflake(message_id) and is_list(opts) do
    reason = opts[:reason]

    {:put, "/channels/#{channel_id}/pins/#{message_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  @doc """
  Unpins a message in a channel.

  ## Permissions

  - 'MANAGE_MESSAGES'

  ## Events

  - `:MESSAGE_UPDATE`
  - `:CHANNEL_PINS_UPDATE`

  ## Examples

      iex> Remedy.API.unpin_message(43189401384091, 18743893102394)
      :ok

  """

  @unsafe {:unpin_message, [:channel_id, :message_id, :opts]}
  @spec unpin_message(snowflake, snowflake, opts) :: :ok | {:error, reason}
  def unpin_message(channel_id, message_id, opts \\ []) do
    reason = opts[:reason]

    {:delete, "/channels/#{channel_id}/pins/#{message_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  ##  Cannot be used by bots. Can only be used by GameSDK
  ##  since: "0.6.0"
  @doc false
  @spec group_dm_add_recipient(snowflake, snowflake) :: :ok | {:error, any}
  @unsafe {:group_dm_add_recipient, [:channel_id, :user_id]}
  def group_dm_add_recipient(channel_id, user_id) do
    {:put, "/channels/#{channel_id}/recipients/#{user_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  ##  Cannot be used by bots. Can only be used by GameSDK
  ##  since: "0.6.0"
  @doc false
  @spec group_dm_remove_recipient(snowflake, snowflake) :: :ok | {:error, any}
  @unsafe {:group_dm_remove_recipient, [:channel_id, :user_id]}
  def group_dm_remove_recipient(channel_id, user_id) do
    {:delete, "/channels/#{channel_id}/recipients/#{user_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Starts a thread with a message.

  ## Events

  - `:THREAD_CREATE`

  ## Option

  - `:name`  - `:string, min: 1, max: 100`
  - `:auto_archive_duration`  - `integer: 60, 1440, 4320, 10080`
  - `:rate_limit_per_user`  - `:integer, min: 0, max: 21600` - Message sending cooldown in seconds.


  """

  @doc since: "0.6.0"
  @unsafe {:create_thread, [:channel_id, :message_id, :opts]}
  def create_thread(channel_id, message_id, opts) do
    data = %{}
    types = %{name: :string, auto_archive_duration: :integer, rate_limit_per_user: :integer}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_length(:name, min: 1, max: 100)
      |> validate_inclusion(:auto_archive_duration, [60, 1440, 4320, 10080])
      |> validate_number(:rate_limit_per_user,
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: 21600
      )

    {:post, "/channels/#{channel_id}/messages/#{message_id}/threads", nil, reason, body}
    |> request()
    |> shape(Thread)
  end

  @doc """
  Creates a thread that is not associated to a message.

  The thread will be a `:GUILD_PRIVATE_THREAD`

  ## Events

  - `:THREAD_CREATE`

  ## Options

  - `:name`  - `:string, min: 1, max: 100`
  - `:type`  - `:integer`
    - `11` - `:GUILD_PUBLIC_THREAD`
    - `12` - `:GUILD_PRIVATE_THREAD`
  - `:invitable`  - `:boolean` - 	whether non-moderators can add other non-moderators to a thread; only available when creating a private thread
  - `:auto_archive_duration`  - `integer: 60, 1440, 4320, 10080`

  ## Examples

      iex> Remedy.API.create_thread(43189401384091, name: "Hello World")
      {:ok, %Thread{}}

  """
  @doc since: "0.6.0"
  @unsafe {:create_thread, [:channel_id, :opts]}
  @spec create_thread(snowflake, opts) :: {:error, reason} | {:ok, Thread.t()}
  def create_thread(channel_id, opts) do
    data = %{}
    types = %{name: :string, auto_archive_duration: :integer, rate_limit_per_user: :integer}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_length(:name, min: 1, max: 100)
      |> validate_inclusion(:auto_archive_duration, [60, 1440, 4320, 10080])
      |> validate_number(:rate_limit_per_user,
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: 21600
      )

    {:post, "/channels/#{channel_id}/threads", nil, reason, body}
    |> request()
    |> shape(Thread)
  end

  @doc """
  Adds a member to a thread.

  ## Events

  - `:THREAD_MEMBERS_UPDATE`
  - `:THREAD_CREATE`

  ## Examples

      iex> Remedy.API.join_thread(thread_the_bot_is_not_yet_in)
      :ok

       iex> Remedy.API.join_thread(thread_the_bot_is_already_in)
      :ok

      iex> Remedy.API.join_thread(a_category_channel)
      {:error, {400, 50024, "Cannot execute action on this channel type"}}


  """
  @doc since: "0.6.0"
  @unsafe {:join_thread, [:channel_id]}
  @spec join_thread(snowflake) :: :ok | {:error, any}
  def join_thread(channel_id) do
    {:put, "/channels/#{channel_id}/thread-members/@me", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Adds another member to a thread.

  Requires the ability to send messages in the thread.
  Also requires the thread is not archived.

  ## Events

  - `:THREAD_MEMBERS_UPDATE`

  ## Examples

      iex> Remedy.API.add_thread_member(channel_id, user_id)
      :ok

  """
  @doc since: "0.6.0"
  @unsafe {:add_thread_member, [:channel_id, :user_id]}
  @spec add_thread_member(snowflake, snowflake) :: {:error, any} | :ok
  def add_thread_member(channel_id, user_id) do
    {:put, "/channels/#{channel_id}/thread-members/#{user_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Leaves a thread.

  Also requires the thread is not archived.

  ## Events

  - `:THREAD_MEMBERS_UPDATE`

  ## Examples

      iex> Remedy.API.leave_thread(channel_id)
      :ok

  """
  @doc since: "0.6.0"
  @unsafe {:leave_thread, [:channel_id]}
  @spec leave_thread(any) :: :ok
  def leave_thread(channel_id) do
    {:delete, "/channels/#{channel_id}/thread-members/@me", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Remove a user from a thread.

  Also requires the thread is not archived.

  ## Events

  - `:THREAD_MEMBERS_UPDATE`

  ## Examples

  iex> Remedy.API.remove_thread_member(channel_id, user_id)
  :ok

  """

  @doc since: "0.6.0"
  @unsafe {:remove_thread_member, [:channel_id, :user_id]}
  @spec remove_thread_member(snowflake, snowflake) :: :ok | {:error, any}
  def remove_thread_member(channel_id, user_id) do
    {:delete, "/channels/#{channel_id}/thread-members/#{user_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc since: "0.6.0"
  @unsafe {:list_thread_members, [:channel_id]}
  @spec list_thread_members(snowflake) :: {:error, reason} | {:ok, [User.t()]}
  def list_thread_members(channel_id) do
    {:get, "/channels/#{channel_id}/thread-members", nil, nil, nil}
    |> request()
    |> shape(User)
  end

  @doc """
  List active threads.

  This can be requested on both the `/channels/` and the `/guilds/` routes. To specify which route is used, you should pass a full `%Guild{}` or `%Channel{}` object.



  """
  @doc since: "0.6.0"
  @unsafe {:list_active_threads, 1}
  @spec list_active_threads(Remedy.Schema.Channel.t() | Remedy.Schema.Guild.t()) ::
          {:error, reason} | {:ok, [Thread.t()]}
  def list_active_threads(%Guild{id: guild_id}) do
    list_active_guild_threads(guild_id)
  end

  def list_active_threads(%Channel{id: channel_id}) do
    list_active_channel_threads(channel_id)
  end

  @doc """
  List the active threads in a channel.

  ## Examples

      iex> Remedy.API.list_active_channel_threads(a_valid_channel)
      {:ok, [%Thread{}]}


  """
  @doc since: "0.6.8"
  @unsafe {:list_active_channel_threads, [:channel_id]}
  @spec list_active_channel_threads(Remedy.Schema.Channel.t()) ::
          {:error, reason} | {:ok, [Thread.t()]}
  def list_active_channel_threads(channel_id) do
    {:get, "/channels/#{channel_id}/threads/active", nil, nil, nil}
    |> request()
    |> shape(Thread)
  end

  @doc """
  List the active threads in a guild.

  ## Examples

      iex> Remedy.API.list_active_guild_threads(a_valid_guild)
      {:ok, [%Thread{}]}


  """
  @doc since: "0.6.8"
  @unsafe {:list_active_guild_threads, [:guild_id]}
  @spec list_active_guild_threads(Remedy.Schema.Guild.t()) ::
          {:error, reason} | {:ok, [Thread.t()]}
  def list_active_guild_threads(guild_id) do
    {:get, "/guilds/#{guild_id}/threads/active", nil, nil, nil}
    |> request()
    |> shape(Thread)
  end

  @doc """
  List public archived threads in the given channel.

  ## Examples

      iex> Remedy.API.list_public_archived_threads(channel_id)
      {:ok, [%Thread{}]}

  """

  @doc since: "0.6.0"
  @unsafe {:list_public_archived_threads, [:channel_id]}
  @spec list_public_archived_threads(snowflake) :: {:error, any} | {:ok, any}
  def list_public_archived_threads(channel_id) do
    {:get, "/channels/#{channel_id}/threads/archived/public", nil, nil, nil}
    |> request()
    |> shape(Thread)
  end

  @doc """
  List private archived threads in the given channel.

  ## Examples

  iex> Remedy.API.list_public_archived_threads(channel_id)
  {:ok, [%Thread{}]}

  """

  @doc since: "0.6.0"
  @unsafe {:list_private_archived_threads, [:channel_id]}
  @spec list_private_archived_threads(snowflake) :: {:ok, [Thread.t()]} | {:error, reason}
  def list_private_archived_threads(channel_id) do
    {:get, "/channels/#{channel_id}/threads/archived/private", nil, nil, nil}
    |> request()
    |> shape(Thread)
  end

  @doc since: "0.6.0"
  @unsafe {:list_joined_private_archived_threads, [:channel_id]}

  @spec list_joined_private_archived_threads(snowflake) :: {:ok, [Thread.t()]} | {:error, reason}
  def list_joined_private_archived_threads(channel_id) do
    {:get, "/channels/#{channel_id}/users/@me/threads/archived/private", nil, nil, nil}
    |> request()
    |> shape(Thread)
  end

  #############################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░███████╗░███╗░░░███╗░░█████╗░░░░░░░██╗░██╗░░██████╗░ ###
  ### ░██╔════╝░████╗░████║░██╔══██╗░░░░░░██║░██║░██╔════╝░ ###
  ### ░█████╗░░░██╔████╔██║░██║░░██║░░░░░░██║░██║░╚█████╗░░ ###
  ### ░██╔══╝░░░██║╚██╔╝██║░██║░░██║░██╗░░██║░██║░░╚═══██╗░ ###
  ### ░███████╗░██║░╚═╝░██║░╚█████╔╝░╚█████╔╝░██║░██████╔╝░ ###
  ### ░╚══════╝░╚═╝░░░░░╚═╝░░╚════╝░░░╚════╝░░╚═╝░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  #############################################################
  @doc """
  Gets a list of emojis for a given guild.

  ## Permissions

  - `:MANAGE_EMOJIS`

  ## Examples

      iex> Remedy.API.list_emojis(guild_id)
      {:ok, [%Emoji{}]}

      iex> Remedy.API.list_emojis(bad_guild_id)
      {:error, reason}

  """
  @doc since: "0.6.0"
  @unsafe {:list_emojis, [:guild_id]}
  @spec list_emojis(snowflake) :: {:error, reason} | {:ok, [Emoji.t()]}
  def list_emojis(guild_id) do
    {:get, "/guilds/#{guild_id}/emojis", nil, nil, nil}
    |> request()
    |> shape(Emoji)
  end

  @doc """
  Gets an emoji for the given guild and emoji ids.

  ## Permissions

  - `:MANAGE_EMOJIS`

  ## Examples

    iex> Remedy.API.get_emoji(guild_id, emoji_id)
    {:ok, %Emoji{}}

    iex Remedy.API.get_emoji(guild_id, bad_emoji_id)
    {:error, reason}

  """
  @doc since: "0.6.0"
  @unsafe {:get_emoji, [:guild_id, :emoji_id]}
  @spec get_emoji(snowflake, snowflake) :: {:error, reason} | {:ok, Emoji.t()}
  def get_emoji(guild_id, emoji_id) do
    {:get, "/guilds/#{guild_id}/emojis/#{emoji_id}", nil, nil, nil}
    |> request()
    |> shape(Emoji)
  end

  @doc """
  Creates a new emoji for the given guild.

  ## Permissions

  - `:MANAGE_EMOJIS`

  ## Events

  - `:EMOJIS_UPDATE`

  An optional `reason` can be provided for the audit log.

  If successful, returns `{:ok, emoji}`. Otherwise, returns {:error, reason}.

  ## Options

    - `:name`
    - `:image`
    - `:roles`
    - `:reason`

  `:name` and `:image` are always required.

  ## Examples

      iex> Remedy.API.create_emoji(43189401384091,
      ...> name: "remedy", image: "data:image/png;base64,YXl5IGJieSB1IGx1a2luIDQgc3VtIGZ1az8=", roles: [])

  """
  @doc since: "0.6.0"
  @unsafe {:create_emoji, [:guild_id, :opts]}
  @spec create_emoji(snowflake, opts) :: {:ok, Emoji.t()} | {:error, reason}
  def create_emoji(guild_id, opts) do
    data = %{}
    types = %{name: :string, image: :string, roles: {:array, Snowflake}, reason: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_required([:name, :image])

    {:post, "/guilds/#{guild_id}/emojis", nil, reason, body}
    |> request()
    |> shape(Emoji)
  end

  @doc """
  Modify the given emoji.

  ## Permissions

  - `:MANAGE_EMOJIS`

  Events

  - `:EMOJIS_UPDATE`

  ## Options

    - `:name`  - `:string`
    - `:roles`  - `[:role]`
    - `:reason`  - `:string`

  ## Examples

      iex> Remedy.API.modify_emoji(43189401384091, 4314301984301, name: "elixir", roles: [])
      {:ok, %Remedy.Schema.Emoji{}}

  """
  @doc since: "0.6.0"
  @unsafe {:modify_emoji, 2}
  @spec modify_emoji(snowflake, snowflake, opts) :: {:ok, Emoji.t()}
  def modify_emoji(guild_id, emoji_id, opts) do
    data = %{}
    types = %{name: :string, roles: {:array, Snowflake}}
    params = Enum.into(opts, %{})
    keys = Map.keys(types)
    reason = opts[:reason]

    body = {data, types} |> cast(params, keys)

    {:patch, "/guilds/#{guild_id}/emojis/#{emoji_id}", nil, reason, body}
    |> request()
  end

  @doc """
  Deletes the given emoji.

  ## Permissions

  - `:MANAGE_EMOJIS`

  ## Events

  - `:EMOJI_UPDATE`

  ## Options

  - `:reason`

  ## Examples

      iex> Remedy.API.delete_emoji(snowflake, snowflake, reason: "Because i felt like it")
      :ok

  """
  @doc since: "0.6.0"
  @spec delete_emoji(snowflake, snowflake, opts) :: :ok | {:error, any}
  @unsafe {:delete_emoji, [:guild_id, :emoji_id, :opts]}
  def delete_emoji(guild_id, emoji_id, opts) do
    reason = Keyword.take(opts, [:reason])

    {:delete, "/guilds/#{guild_id}/emojis/#{emoji_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  ############################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░░██████╗░░██╗░░░██╗░██╗░██╗░░░░░░██████╗░░░██████╗░ ###
  ### ░██╔════╝░░██║░░░██║░██║░██║░░░░░░██╔══██╗░██╔════╝░ ###
  ### ░██║░░██╗░░██║░░░██║░██║░██║░░░░░░██║░░██║░╚█████╗░░ ###
  ### ░██║░░╚██╗░██║░░░██║░██║░██║░░░░░░██║░░██║░░╚═══██╗░ ###
  ### ░╚██████╔╝░╚██████╔╝░██║░███████╗░██████╔╝░██████╔╝░ ###
  ### ░░╚═════╝░░░╚═════╝░░╚═╝░╚══════╝░╚═════╝░░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ############################################################

  @doc """
  Create a guild.

  This endpoint can be used only by bots in less than 10 guilds.

  ## Events

  - `:GUILD_CREATE`

  ## Options

  - `:name`  - `:string, min: 2, max: 100`
  - `:icon`  - `:image_data`
  - `:verification_level`  - `:integer`
    - `0`  - `:none` - unrestricted
    - `1`  - `:low` - must have verified email on account
    - `2`  - `:medium` - must be registered on Discord for longer than 5 minutes
    - `3`  - `:high` - must be a member of the server for longer than 10 minutes
    - `4`  - `:very_high` - must have a verified phone number
  - `:default_message_notifications`  - `:integer`
  - `:explicit_content_filter`  - `:integer`
    - `0`  - `:disabled`
    - `1`  - `:members_without_roles`
    - `2`  - `:all_members`
  - `:roles`  - `{:array, :role}`
  - `:channels`  - `{:array, :channel}`
  - `:afl_channel_id`  - `:snowflake`
  - `:afk_timeout`  - `:integer, :seconds`

  ## Examples

      iex> Remedy.API.create_guild(name: "Test Server For Testing")


  > When using the `:roles` parameter, the first member of the array is used to change properties of the guild's `@everyone` role. If you are trying to bootstrap a guild with additional roles, keep this in mind.

  > When using the `:roles` parameter, the required id field within each role object is an integer placeholder, and will be replaced by the API upon consumption. Its purpose is to allow you to overwrite a role's permissions in a channel when also passing in channels with the channels array.

  > When using the `:channels` parameter, the `:position` field is ignored, and none of the default channels are created.

  > When using the `:channels` parameter, the id field within each channel object may be set to an integer placeholder, and will be replaced by the API upon consumption. Its purpose is to allow you to create `:GUILD_CATEGORY` channels by setting the `:parent_id` field on any children to the category's id field. Category channels must be listed before any children.


  """
  @doc since: "0.6.0"
  @unsafe {:create_guild, [:opts]}
  @spec create_guild(opts) :: {:error, reason} | {:ok, Guild.t()}
  def create_guild(opts) do
    params = Enum.into(opts, %{})
    data = %{}

    types = %{
      name: :string,
      region: :string,
      verification_level: :integer,
      default_message_notificat: :integer,
      explicit_content_filter: :integer,
      afk_channel_id: Snowflake,
      afk_timeoujt: :integer,
      icon: :string,
      owner_id: Snowflake,
      splash: :string,
      system_channel_id: Snowflake,
      rules_channel_id: Snowflake,
      public_updates_channel_id: Snowflake
    }

    body =
      {data, types}
      |> cast(params, Map.keys(types))
      |> validate_required([:name])
      |> validate_length(:name, min: 2, max: 100)

    {:post, "/guilds", nil, nil, body}
    |> request()
    |> shape(Guild)
  end

  @doc """
  Gets a guild.

  ## Examples

      iex> Remedy.API.get_guild(81384788765712384)
      {:ok, %Remedy.Schema.Guild{id: 81384788765712384}}

  """
  @doc since: "0.6.0"
  @unsafe {:get_guild, [:guild_id]}
  def get_guild(guild_id) do
    {:get, "/guilds/#{guild_id}", nil, nil, nil}
    |> request()
  end

  @doc """
  Modifies a guild's settings.

  ## Permissions

  - `MANAGE_GUILD`

  ## Events

  - `:GUILD_UPDATE`

  ## Options

  - `:name`  - `:string, min: 2, max: 100`
  - `:icon`  - `:image_data`
  - `:verification_level`  - `:integer`
    - `0`  - `:none` - unrestricted
    - `1`  - `:low` - must have verified email on account
    - `2`  - `:medium` - must be registered on Discord for longer than 5 minutes
    - `3`  - `:high` - must be a member of the server for longer than 10 minutes
    - `4`  - `:very_high` - must have a verified phone number
  - `:default_message_notifications`  - `:integer`
    - `0`  - `:all_messages` - members will receive notifications for all messages by default
    - `1`  - `:only_mentions` - members will receive notifications only for mentions by default
  - `:explicit_content_filter`  - `:integer`
    - `0`  - `:disabled`
    - `1`  - `:members_without_roles`
    - `2`  - `:all_members`
  - `:roles`  - `{:array, :role}`
  - `:channels`  - `{:array, :channel}`
  - `:afk_channel_id`  - `:snowflake`
  - `:afk_timeout`  - `:integer, :seconds`
  - `:icon`  - `:string`
  - `:owner_id`  - `Snowflake` - to transfer guild ownership to (must be owner)
  - `:splash`  - `:string`
  - `:system_channel_id` - `Snowflake`
  - `:rules_channel_id`  - `Snowflake`
  - `:public_updates_channel_id`  - `Snowflake`

  ## Examples

      iex> Remedy.API.modify_guild(451824027976073216, name: "Nose Drum")
      {:ok, %Remedy.Schema.Guild{id: 451824027976073216, name: "Nose Drum", ...}}

  """
  @unsafe {:modify_guild, [:guild_id, :opts]}
  def modify_guild(guild_id, opts) do
    reason = opts[:reason]
    data = %{}

    types = %{
      name: :string,
      icon: :string,
      verification_level: :integer,
      default_message_notificat: :integer,
      explicit_content_filter: :integer,
      afk_channel_id: Snowflake,
      afk_timeoujt: :integer,
      owner_id: Snowflake,
      splash: :string,
      system_channel_id: Snowflake,
      rules_channel_id: Snowflake,
      public_updates_channel_id: Snowflake
    }

    body =
      {data, types}
      |> cast(opts, Map.keys(types))
      |> validate_length(:name, min: 2, max: 100)
      |> validate_inclusion(:verification_level, [0, 1, 2, 3, 4])
      |> validate_inclusion(:default_message_notifications, [0, 1])
      |> validate_inclusion(:explicit_content_filter, [0, 1, 2])

    {:patch, "/guilds/#{guild_id}", nil, reason, body}
    |> request()
  end

  @doc """
  Deletes a guild.

  This endpoint requires that the current user is the owner of the guild.

  ## Events

  - `:GUILD_DELETE`

  ## Examples

      iex> Remedy.API.delete_guild(618432108653707274)
      {:error, {403, 50001, "Missing Access"}}

      iex> Remedy.API.delete_guild(618432108653707274)
      {:error, {403, 50001, "Missing Access"}}

  """

  @unsafe {:delete_guild, 1}
  def delete_guild(guild_id) do
    {:delete, "/guilds/#{guild_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  List guild channels.

  Does not include threads

  ## Permissions

  -

  ## Events

  -

  ## Options

  -

  ## Examples

      iex> Remedy.API.list_channels(81384788765712384)
      {:ok, [%Remedy.Schema.Channel{guild_id: 81384788765712384}]}

  """

  @doc since: "0.6.0"
  @unsafe {:list_channels, [:guild_id]}
  @spec list_channels(snowflake) :: {:error, reason} | {:ok, [Channel.t()]}
  def list_channels(guild_id) do
    {:get, "/guilds/#{guild_id}/channels", nil, nil, nil}
    |> request()
    |> shape(Channel)
  end

  @doc """
  Creates a channel for a guild.

  ## Permissions

  - `MANAGE_CHANNELS`

  ## Events

  - `:CHANNEL_CREATE`

  ## Options

  - `:name`  - `:string, min: 2, max: 100`
  - `:type` - `t:Remedy.Schema.Channel.t/0`
  - `:topic`  - `:string, min: 8, max: 256`
  - `:bitrate`  - `:integer, min: 8, max: 256`
  - `:user_limit`  - `:integer, min: 1, max: 99, unlimited: 0`
  - `:permission_overwrites`  - `[t:Remedy.Schema.PermissionOverwrite.t/0]`
  - `:parent_id`  - `t:Snowflake.t/0` - Category to place the channel under.
  - `:nsfw`  - `:boolean`

  ## Examples

      iex> Remedy.API.create_channel(81384788765712384, name: "elixir-remedy", topic: "steve's domain")
      {:ok, %Remedy.Schema.Channel{guild_id: 81384788765712384}}

  """
  @doc since: "0.6.8"
  @unsafe {:create_channel, [:guild_id, :opts]}
  @spec create_channel(snowflake, opts) :: {:error, any} | {:ok, any}
  def create_channel(guild_id, opts) do
    data = %{name: "", nsfw: false, user_limit: 0}

    types = %{
      name: :string,
      type: :integer,
      topic: :string,
      bitrate: :integer,
      user_limit: :integer,
      permission_overwrites: {:array, :map},
      parent_id: Snowflake,
      nsfw: :boolean
    }

    keys = Map.keys(types)
    _reason = opts[:reason]
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_length(:name, min: 2, max: 100)
      |> validate_length(:topic, min: 2, max: 100)
      |> validate_number(:bitrate, min: 8000, max: 128_000)
      |> validate_number(:user_limit, min: 0, max: 99)

    {:post, "/guilds/#{guild_id}/channels", nil, nil, body}
    |> request()
  end

  @doc """
  Reorders a guild's channels.

  ## Permissions

  - `MANAGE_CHANNELS`

  ## Events

  - `:CHANNEL_UPDATE`

  ## Options

  - `positions`

  ## Examples

      iex> Remedy.API.modify_channel_positions(279093381723062272, [%{id: 351500354581692420, position: 2}])
      {:ok}

      iex> Remedy.API.modify_channel_positions(279093381723062272, [%{id: 351500354581692420, position: 2}])
      {:ok}

  """
  def modify_channel_positions(guild_id, opts) do
    body = opts

    {:patch, "/guilds/#{guild_id}/channels", nil, nil, body}
    |> request()
  end

  @doc """
  Gets a guild member.

  ## Examples

      iex> Remedy.API.get_member(4019283754613, 184937267485)

  """
  @doc since: "0.6.0"
  @unsafe {:get_member, [:guild_id, :user_id]}
  @spec get_member(snowflake, snowflake) :: {:error, reason} | {:ok, Member.t()}
  def get_member(guild_id, user_id) do
    {:get, "/guilds/#{guild_id}/members/#{user_id}", nil, nil, nil}
    |> request()
    |> shape(Member)
  end

  @doc """
  Gets a list of a guild's members.

  ## Options

    - `:limit`  - `:integer, min: 1, max: 1000, default: 1`
    - `:after`  - `Snowflake, default: 0` - get members after this user ID

  ## Examples

      iex>  Remedy.API.list_members(41771983423143937, limit: 1)
      {:ok, [%Remedy.Schema.GuildMember{user_id: 184937267485}]}

  """
  @doc since: "0.6.8"
  @unsafe {:list_members, [:guild_id, :opts]}
  @spec list_members(snowflake, opts) :: {:error, reason} | {:ok, [GuildMember.t()]}
  def list_members(guild_id, opts) do
    data = %{limit: 1, after: 0}
    types = %{limit: :integer, after: Snowflake}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:limit, greater_than: 0, less_than_or_equal_to: 1000)

    {:get, "/guilds/#{guild_id}/members", nil, nil, body}
    |> request()
    |> shape(Member)
  end

  @doc """
  Search for a guild member.

  ## Options

  - `:limit`  - `:integer, min: 1, max: 1000, default: 1`
  - `:query`  - `:string` - Matches against nickname and username

  ## Examples

      iex> Remedy.API.search_members(41771983423143937, query: "steve")
      {:ok, [%Remedy.Schema.GuildMember{user_id: 184937267485}]}


  """
  @doc since: "0.6.0"
  @unsafe {:search_members, [:guild_id, :opts]}
  @spec search_members(snowflake, opts) :: {:error, reason} | {:ok, [GuildMember.t()]}
  def search_members(guild_id, opts) do
    data = %{limit: 1}
    types = %{limit: :integer, query: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    query_params =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:limit, greater_than: 0, less_than_or_equal_to: 1000)

    {:get, "/guilds/#{guild_id}/members/search", query_params, nil, nil}
    |> request()
  end

  ## @doc """
  ## Puts a user in a guild.
  ##
  #### Permissions
  ##
  ## - `CREATE_INSTANT_INVITE`
  ## - `MANAGE_NICKNAMES`*
  ## - `MANAGE_ROLES`*
  ## - `MUTE_MEMBERS`*
  ## - `DEAFEN_MEMBERS`*
  ##
  #### Events
  ##
  ## - `:member_ADD`
  ##
  #### Options
  ##
  ##  - `:access_token`  - `:string` - the user's oauth2 access token
  ##  - `:nick`  - `:string` - value to set users nickname to
  ##  - `:roles`  - `{:array, Snowflake} - array of role ids the member is assigned
  ##  - `:mute`  `:boolean` - if the user is muted
  ##  - `:deaf`  `:boolean` - if the user is deafened
  ##
  ## `:access_token` is always required.
  ##
  #### Examples
  ##
  ##    iex> Remedy.API.add_member(
  ##    ...> 41771983423143937,
  ##    ...> 18374719829378473,
  ##    ...> access_token: "6qrZcUqja7812RVdnEKjpzOL4CvHBFG",
  ##    ...> nick: "remedy",
  ##    ...> roles: [431849301, 913809431])
  ##
  ## """
  @doc false
  @unsafe {:add_member, [:guild_id, :user_id, :opts]}
  @spec add_member(snowflake, snowflake, opts) :: {:error, any} | {:ok, any}
  def add_member(guild_id, user_id, opts) do
    data = %{}

    types = %{
      access_token: :string,
      nick: :string,
      roles: {:array, Snowflake},
      mute: :boolean,
      deaf: :boolean
    }

    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:put, "/guilds/#{guild_id}/members/#{user_id}", nil, nil, body}
    |> request()
  end

  @doc """
  Modifies a guild member's attributes.

  ## Permissions

  - `:MANAGE_NICKNAMES`
  - `:MANAGE_ROLES`
  - `:MUTE_MEMBERS`
  - `:DEAFEN_MEMBERS`
  - `:MOVE_MEMBERS`

  ## Events

  - `:member_UPDATE`

  ## Options

  - `:nick`  - `:string` - value to set users nickname to
  - `:roles`  - `{:array, Snowflake}` - of role ids the member is assigned
  - `:mute`  -  `:boolean` - if the user is muted
  - `:deaf`  - `:boolean` - if the user is deafened
  - `:channel_id`  - `Snowflake` - id of channel to move user to (if they are connected to voice)
  - `:reason`

  ## Examples

      iex> Remedy.API.modify_member(41771983423143937, 637162356451, nick: "Remedy")
      :ok

  """
  @doc since: "0.6.0"
  @unsafe {:modify_member, [:guild_id, :user_id, :opts]}
  @spec modify_member(snowflake, snowflake, opts) :: {:error, any} | {:ok, any}
  def modify_member(guild_id, user_id, opts) do
    data = %{}

    types = %{
      nick: :string,
      roles: {:array, Snowflake},
      mute: :boolean,
      deaf: :boolean,
      channel_id: Snowflake,
      reason: :string
    }

    keys = Map.keys(types)
    params = Enum.into(opts, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/guilds/#{guild_id}/members/#{user_id}", nil, reason, body}
    |> request()
    |> shape(Member)
  end

  @doc """
  Changes the attributes of the bots guild profile.

  ## Permissions

  - `:CHANGE_NICKNAME`

  ## Events

  - `:GUILD_MEMBER_UPDATE`

  ## Options

    - `:nick`  - `:string` - value to set bots nickname in the guild
    - `:reason`  - `:string`

  ## Examples

      iex> Remedy.API.modify_bot(41771983423143937, nick: "Remedy")
      {:ok, %{nick: "Remedy"}}

  """
  @doc since: "0.6.8"
  @unsafe {:modify_bot, [:guild_id, :opts]}
  @spec modify_bot(snowflake, opts) :: {:error, reason} | {:ok, Member.t()}
  def modify_bot(guild_id, opts) do
    data = %{}
    types = %{nick: :string}
    reason = opts[:reason]
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/guilds/#{guild_id}/members/@me", nil, reason, body}
    |> request()
    |> shape(Member)
  end

  @doc """
  Adds a role to a member of a guild.

  ## Permissions

  - `:MANAGE_ROLES`

  ## Events

  - `:GUILD_MEMBER_UPDATE`

  ## Options

  - `:reason`  - `:string`

  ## Examples

      iex> Remedy.API.add_role(41771983423143937, 637162356451, 431849301)
      {:ok, %{roles: [431849301]}}

  """
  @doc method: "PUT"
  @doc route: "guilds/:guild_id/members/:user_id/roles/:role_id"
  @doc since: "0.6.8"
  @unsafe {:add_role, [:guild_id, :user_id, :role_id, :opts]}
  @spec add_role(snowflake, snowflake, snowflake, opts) :: {:error, reason} | {:ok, Member.t()}
  def add_role(guild_id, user_id, role_id, opts) do
    reason = opts[:reason]

    {:put, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", nil, reason, nil}
    |> request()
  end

  @doc """
  Removes a role from a member.

  Role to remove is specified by `role_id`.
  User to remove role from is specified by `guild_id` and `user_id`.
  An optional `reason` can be given for the audit log.
  """

  def remove_role(guild_id, user_id, role_id, opts) do
    reason = opts[:reason]

    {:delete, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", nil, reason, nil}
    |> request()
  end

  @doc """
  Removes a member from a guild.

  This event requires the `KICK_MEMBERS` permission. It fires a
  `t:Remedy.Consumer.member_remove/0` event.

  An optional reason can be provided for the audit log with `reason`.

  If successful, returns `{:ok}`. Otherwise, returns a {:error, reason}.

  ## Examples

      iex> Remedy.API.remove_member(1453827904102291, 18739485766253)
      {:ok}

  """
  def kick_user(guild_id, user_id) do
    {:delete, "/guilds/#{guild_id}/members/#{user_id}"}
    |> request()
  end

  @doc """
  Gets a list of users banned from a guild.

  Guild to get bans for is specified by `guild_id`.

  """
  @doc since: "0.6"
  def list_bans(guild_id) do
    {:get, "/guilds/#{guild_id}/bans"}
    |> request()
  end

  @doc """
  Gets a ban object for the given user from a guild.


  """

  def get_ban(guild_id, user_id) do
    {:get, "/guilds/#{guild_id}/bans/#{user_id}"}
    |> request()
  end

  @doc """
  Bans a user from a guild.

  User to delete is specified by `guild_id` and `user_id`.
  An optional `reason` can be specified for the audit log.
  """

  def ban_user(guild_id, user_id) do
    {:put, "/guilds/#{guild_id}/bans/#{user_id}"}
    |> request()
  end

  @doc """
  Removes a ban for a user.

  ## Options

  - `:reason`  - Reason for the audit log.

  ## Examples

      iex> Remedy.API.remove_guild_ban(guild_id, user_id)
      :ok


  """
  @doc since: "0.6.8"
  @unsafe {:unban, [:guild_id, :user_id, :opts]}
  @spec unban(snowflake, snowflake, opts) :: :ok | {:error, reason}
  def unban(guild_id, user_id, opts) do
    reason = Keyword.take(opts, :reason)

    {:delete, "/guilds/#{guild_id}/bans/#{user_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  @doc """
  Gets a guild's roles.

  ## Examples

      iex>  Remedy.API.get_guild_roles(147362948571673)
      {:ok, [%Remedy.Schema.Role{}]}

  """
  @doc since: "0.6.0"
  @unsafe {:list_guild_roles, [:guild_id]}
  @spec list_guild_roles(snowflake) :: {:ok, [Role.t()]} | {:error, reason}
  def list_guild_roles(guild_id) do
    {:get, "/guilds/#{guild_id}/roles", nil, nil, nil}
    |> request()
    |> shape(Role)
  end

  @doc """
  Creates a guild role.

  An optional reason for the audit log can be provided via `reason`.

  This endpoint requires the `MANAGE_ROLES` permission. It fires a
  `t:Remedy.Consumer.guild_role_create/0` event.

  If successful, returns `{:ok, role}`. Otherwise, returns a {:error, reason}.

  ## Options

    - `:name` (string) - name of the role (default: "new role")
    - `:permissions` (integer) - bitwise of the enabled/disabled permissions (default: @everyone perms)
    - `:color` (integer) - RGB color value (default: 0)
    - `:hoist` (boolean) - whether the role should be displayed separately in the sidebar (default: false)
    - `:mentionable` (boolean) - whether the role should be mentionable (default: false)

  ## Examples

      iex> Remedy.API.create_guild_role(41771983423143937, name: "remedy-club", hoist: true)
      {:ok, %Remedy.Schema.Role{}}

  """
  def create_role(guild_id) do
    {:post, "/guilds/#{guild_id}/roles"}
  end

  @doc """
  Reorders a guild's roles.

  This endpoint requires the `MANAGE_ROLES` permission. It fires multiple
  `t:Remedy.Consumer.guild_role_update/0` events.

  If successful, returns `{:ok, roles}`. Otherwise, returns a {:error, reason}.

  `positions` is a list of maps that each map a role id with a position.

  ## Examples

      iex> Remedy.API.modify_guild_role_positions(41771983423143937, [%{id: 41771983423143936, position: 2}])

  """
  def modify_role_positions(guild_id) do
    {:patch, "/guilds/#{guild_id}/roles"}
  end

  @doc """
  Modifies a guild role.

  This endpoint requires the `MANAGE_ROLES` permission. It fires a
  `t:Remedy.Consumer.guild_role_update/0` event.

  An optional `reason` can be specified for the audit log.

  If successful, returns `{:ok, role}`. Otherwise, returns a {:error, reason}.

  ## Options

    - `:name` (string) - name of the role
    - `:permissions` (integer) - bitwise of the enabled/disabled permissions
    - `:color` (integer) - RGB color value (default: 0)
    - `:hoist` (boolean) - whether the role should be displayed separately in the sidebar
    - `:mentionable` (boolean) - whether the role should be mentionable

  ## Examples

      iex> Remedy.API.modify_guild_role(41771983423143937, 392817238471936, hoist: false, name: "foo-bar")

  """
  def modify_role(guild_id, role_id) do
    {:patch, "/guilds/#{guild_id}/roles/#{role_id}"}
  end

  @doc """
  Deletes a role from a guild.

  An optional `reason` can be specified for the audit log.

  This endpoint requires the `MANAGE_ROLES` permission. It fires a
  `t:Remedy.Consumer.guild_role_delete/0` event.

  If successful, returns `{:ok}`. Otherwise, returns a {:error, reason}.

  ## Examples

      iex> Remedy.API.delete_guild_role(41771983423143937, 392817238471936)

  """
  def delete_role(guild_id, role_id) do
    {:delete, "/guilds/#{guild_id}/roles/#{role_id}"}
  end

  @doc """
  Gets the number of members that would be removed in a prune given `days`.

  This endpoint requires the `KICK_MEMBERS` permission.

  If successful, returns `{:ok, %{pruned: pruned}}`. Otherwise, returns a {:error, reason}.

  ## Examples

      iex> Remedy.API.get_guild_prune_count(81384788765712384, 1)
      {:ok, %{pruned: 0}}

  """

  def get_prune_count(guild_id) do
    {:get, "/guilds/#{guild_id}/prune"}
  end

  @doc """
  Begins a guild prune to prune members within `days`.

  An optional `reason` can be provided for the guild audit log.

  This endpoint requires the `KICK_MEMBERS` permission. It fires multiple
  `t:Remedy.Consumer.member_remove/0` events.

  If successful, returns `{:ok, %{pruned: pruned}}`. Otherwise, returns a {:error, reason}.

  ## Examples

      iex> Remedy.API.begin_guild_prune(81384788765712384, 1)
      {:ok, %{pruned: 0}}

  """

  def start_prune(guild_id) do
    {:post, "/guilds/#{guild_id}/prune"}
  end

  @doc """
  Gets a list of voice regions for the guild.

  Guild to get voice regions for is specified by `guild_id`.
  """

  def list_guild_voice_regions(guild_id) do
    {:get, "/guilds/#{guild_id}/regions"}
  end

  @doc """
  Gets a list of invites for a guild.

  This endpoint requires the `MANAGE_GUILD` permission.

  If successful, returns `{:ok, invites}`. Otherwise, returns a {:error, reason}.

  ## Examples

      iex> Remedy.API.get_guild_invites(81384788765712384)
      {:ok, [%Remedy.Schema.Invite{}]}

  """
  @doc since: "0.6"
  def list_guild_invites(guild_id) do
    {:get, "/guilds/#{guild_id}/invites"}
  end

  @doc """
  Gets a list of guild integerations.

  Guild to get integrations for is specified by `guild_id`.
  """
  def list_integrations(guild_id) do
    {:get, "/guilds/#{guild_id}/integrations"}
  end

  @doc """
  Deletes a guild integeration.

  Integration to delete is specified by `guild_id` and `integeration_id`.
  """
  def delete_integration(guild_id, integration_id) do
    {:get, "/guilds/#{guild_id}/integrations/#{integration_id}", nil, nil, nil}
    |> request()
    |> shape(Integration)
  end

  @doc since: "0.6.0"
  def get_widget_settings(guild_id) do
    {:get, "/guilds/#{guild_id}/widget"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_widget(guild_id) do
    {:get, "/guilds/#{guild_id}/widget.json"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_vanity_url(guild_id) do
    {:get, "/guilds/#{guild_id}/vanity-url"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_widget_image(guild_id) do
    {:get, "/guilds/#{guild_id}/widget.png"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_welcome_screen(guild_id) do
    {:get, "/guilds/#{guild_id}/welcome-screen"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_welcome_screen(guild_id) do
    {:patch, "/guilds/#{guild_id}/welcome-screen"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_bot_voice_state(guild_id) do
    {:patch, "/guilds/#{guild_id}/voice-states/@me"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_user_voice_state(guild_id, user_id) do
    {:patch, "/guilds/#{guild_id}/voice-states/#{user_id}"}
    |> request()
  end

  ## Guild Template
  @doc """
  Get a guild template from the code or the full URL. eg: https://discord.new/2KAaMpa22ea6

  ## Examples

      iex>

  """
  @doc since: "0.6.0"
  @spec get_guild_template(any) :: {:error, reason} | {:ok, any}
  def get_guild_template("https://discord.new/" <> template_code),
    do: get_guild_template(template_code)

  def get_guild_template(template_code) do
    {:get, "/guilds/templates/#{template_code}", nil, nil, nil}
    |> request()
  end

  @doc since: "0.6.0"
  def create_guild_from_template(template_code) do
    {:post, "/guilds/templates/#{template_code}"}
    |> request()
  end

  @doc since: "0.6.0"
  def create_guild_template(guild_id) do
    {:post, "/guilds/#{guild_id}/templates"}
    |> request()
  end

  @doc since: "0.6.0"
  def sync_guild_from_template(guild_id, template_code) do
    {:put, "/guilds/#{guild_id}/templates/#{template_code}"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_guild_template(guild_id, template_code) do
    {:patch, "/guilds/#{guild_id}/templates/#{template_code}"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_guild_template(guild_id, template_code) do
    {:delete, "/guilds/#{guild_id}/templates/#{template_code}"}
    |> request()
  end

  #################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░██╗░███╗░░██╗░██╗░░░██╗░██╗░████████╗░███████╗░░██████╗░ ###
  ### ░██║░████╗░██║░██║░░░██║░██║░╚══██╔══╝░██╔════╝░██╔════╝░ ###
  ### ░██║░██╔██╗██║░╚██╗░██╔╝░██║░░░░██║░░░░█████╗░░░╚█████╗░░ ###
  ### ░██║░██║╚████║░░╚████╔╝░░██║░░░░██║░░░░██╔══╝░░░░╚═══██╗░ ###
  ### ░██║░██║░╚███║░░░╚██╔╝░░░██║░░░░██║░░░░███████╗░██████╔╝░ ###
  ### ░╚═╝░╚═╝░░╚══╝░░░░╚═╝░░░░╚═╝░░░░╚═╝░░░░╚══════╝░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  #################################################################
  @doc """
  Gets an invite by its `invite_code`.

  If successful, returns `{:ok, invite}`. Otherwise, returns a
  {:error, reason}.

  ## Options

    - `:with_counts` (boolean) - whether to include member count fields

  ## Examples

      iex> Remedy.API.get_invite("zsjUsC")
      {:ok, %Remedy.Schema.Invite{}}

      iex> Remedy.API.get_invite("zsjUsC", with_counts: true)
      {:ok, %Remedy.Schema.Invite{}}

  """
  def get_invite(invite_code) do
    {:get, "/invites/#{invite_code}"}
    |> request()
  end

  @doc """
  Deletes an invite by its `invite_code`.

  This endpoint requires the `MANAGE_CHANNELS` permission.

  If successful, returns `{:ok, invite}`. Otherwise, returns a
  {:error, reason}.

  ## Examples

      iex> Remedy.API.delete_invite("zsjUsC")
      {:ok, %Remedy.Schema.Invite{}}
  """
  def delete_invite(invite_code) do
    {:delete, "/invites/#{invite_code}"}
    |> request()
  end

  #################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░░██████╗░████████╗░░█████╗░░░██████╗░░███████╗░░██████╗░ ###
  ### ░██╔════╝░╚══██╔══╝░██╔══██╗░██╔════╝░░██╔════╝░██╔════╝░ ###
  ### ░╚█████╗░░░░░██║░░░░███████║░██║░░██╗░░█████╗░░░╚█████╗░░ ###
  ### ░░╚═══██╗░░░░██║░░░░██╔══██║░██║░░╚██╗░██╔══╝░░░░╚═══██╗░ ###
  ### ░██████╔╝░░░░██║░░░░██║░░██║░╚██████╔╝░███████╗░██████╔╝░ ###
  ### ░╚═════╝░░░░░╚═╝░░░░╚═╝░░╚═╝░░╚═════╝░░╚══════╝░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  #################################################################

  @doc since: "0.6.0"
  def create_stage do
    {:post, "/stage-instances"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_stage(channel_id) do
    {:get, "/stage-instances/#{channel_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_stage(channel_id) do
    {:patch, "/stage-instances/#{channel_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_stage(channel_id) do
    {:delete, "/stage-instances/#{channel_id}"}
    |> request()
  end

  #############################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░░██████╗░████████╗░██╗░░█████╗░░██╗░░██╗░███████╗░██████╗░░░██████╗░ ###
  ### ░██╔════╝░╚══██╔══╝░██║░██╔══██╗░██║░██╔╝░██╔════╝░██╔══██╗░██╔════╝░ ###
  ### ░╚█████╗░░░░░██║░░░░██║░██║░░╚═╝░█████═╝░░█████╗░░░██████╔╝░╚█████╗░░ ###
  ### ░░╚═══██╗░░░░██║░░░░██║░██║░░██╗░██╔═██╗░░██╔══╝░░░██╔══██╗░░╚═══██╗░ ###
  ### ░██████╔╝░░░░██║░░░░██║░╚█████╔╝░██║░╚██╗░███████╗░██║░░██║░██████╔╝░ ###
  ### ░╚═════╝░░░░░╚═╝░░░░╚═╝░░╚════╝░░╚═╝░░╚═╝░╚══════╝░╚═╝░░╚═╝░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  #############################################################################

  @doc """
  Returns a sticker object.

  ## Examples

      iex> Remedy.API.get_sticker(818599312882794506)
      {:ok, %Remedy.Schema.Sticker{}}

      iex> Remedy.API.get_sticker(123)
      {:error, {404, 10060, "Unknown sticker"}}

  """
  @doc since: "0.6.0"
  @unsafe {:get_sticker, [:sticker_id]}
  @spec get_sticker(snowflake) :: {:error, any} | {:ok, %Sticker{}}
  def get_sticker(sticker_id) do
    {:get, "/stickers/#{sticker_id}", nil, nil, nil}
    |> request()
    |> shape(Sticker)
  end

  ##  @doc """
  ##  List the Nitro Sticker Packs
  ##  """
  ##
  ##  @doc since: "0.6.0"
  @unsafe {:list_nitro_sticker_packs, []}
  @spec list_nitro_sticker_packs() :: {:error, reason} | {:ok, [Sticker.t()]}
  def list_nitro_sticker_packs do
    {:get, "/sticker-packs", nil, nil, nil}
    |> request()
    |> shape(StickerPack)
  end

  @doc """
  List all custom stickers for a guild id.

  ## Examples

      iex> Remedy.API.list_stickers(guild_id)
      {:ok, [%Sticker{}]}

      iex> Remedy.API.get_sticker(123)
      {:error, {404, 10060, "Unknown guild"}}

  """

  @doc since: "0.6.0"
  @unsafe {:list_stickers, [:guild_id]}
  @spec list_stickers(snowflake) :: {:error, reason} | {:ok, [Sticker.t()]}
  def list_stickers(guild_id) do
    {:get, "/guilds/#{guild_id}/stickers", nil, nil, nil}
    |> request()
    |> shape(Sticker)
  end

  @doc """
  Gets a guild sticker by ID.

  ## Examples

      iex> Remedy.API.get_sticker(guild_id, sticker_id)
      {:ok, %Sticker{}}

      iex Remedy.API.get_sticker(bad_guild_id, sticker_id)
      {:error, {404, 10060, "Unknown guild"}}

      iex> Remedy.API.get_sticker(guild_id, bad_sticker_id)
      {:error, {404, 10060, "Unknown Sticker"}}

  """
  @doc since: "0.6.0"
  @unsafe {:get_sticker, [:guild_id, :sticker_id]}
  @spec get_sticker(snowflake, snowflake) :: {:error, reason} | {:ok, Sticker.t()}
  def get_sticker(guild_id, sticker_id) do
    {:get, "/guilds/#{guild_id}/stickers/#{sticker_id}", nil, nil, nil}
    |> request()
    |> shape(Sticker)
  end

  @doc """
  Creates a new sticker under the given guild.

  ## Options

  - `:name, :string, min: 2, max: 30` - name of the sticker (2-30 characters)
  - `:description, :string, min: 2, max: 30` - description of the sticker (empty or 2-100 characters)
  - `:tags, :string, max: 200` - autocomplete/suggestion tags for the sticker (max 200 characters)\
  - `:file, :file_contents` - the sticker file to upload, must be a PNG, APNG, or Lottie JSON file, max 500 KB

  ## Examples

      iex> Remedy.API.create_sticker(guild_id, channel_id, sticker_map)
      {:ok, Sticker.t()}

      iex> Remedy.API.create_sticker(guild_id, channel_id, bad_sticker_map)
      {:error, {404, 10060, "Invalid Form Body"}}

  """

  @doc since: "0.6.0"
  @unsafe {:create_sticker, [:guild_id, :sticker_id, :opts]}
  @spec create_sticker(snowflake, snowflake, opts) :: {:error, reason} | {:ok, Sticker.t()}
  def create_sticker(guild_id, sticker_id, opts \\ []) do
    data = %{}
    types = %{name: :string, description: :string, tags: :string, file: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:post, "/guilds/#{guild_id}/stickers/#{sticker_id}", nil, nil, body}
    |> request()
    |> shape(Sticker)
  end

  @doc since: "0.6.0"
  def modify_sticker(guild_id, sticker_id) do
    {:patch, "/guilds/#{guild_id}/stickers/#{sticker_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_sticker(guild_id, sticker_id) do
    {:delete, "/guilds/#{guild_id}/stickers/#{sticker_id}"}
    |> request()
  end

  #######################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░██╗░░░██╗░░██████╗░███████╗░██████╗░░░██████╗░ ###
  ### ░██║░░░██║░██╔════╝░██╔════╝░██╔══██╗░██╔════╝░ ###
  ### ░██║░░░██║░╚█████╗░░█████╗░░░██████╔╝░╚█████╗░░ ###
  ### ░██║░░░██║░░╚═══██╗░██╔══╝░░░██╔══██╗░░╚═══██╗░ ###
  ### ░╚██████╔╝░██████╔╝░███████╗░██║░░██║░██████╔╝░ ###
  ### ░░╚═════╝░░╚═════╝░░╚══════╝░╚═╝░░╚═╝░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  #######################################################

  @doc """
  Gets info on the bot.

  ## Examples

      iex> Remedy.API.get_bot()
      {:ok, %Remedy.Schema.User{
        id: 883307747305725972,
        avatar: "973a059282550a9ffaca42e795d8330b",
        username: "Remedy",
        ...
        }
      }

  """
  @doc since: "0.6.0"
  @unsafe {:get_bot, []}
  @spec get_bot :: {:error, reason} | {:ok, User.t()}
  def get_bot do
    {:get, "/users/@me", nil, nil, nil}
    |> request()
    |> shape(User)
  end

  @doc """
  Get a user by id.

  ## Examples

      iex> Remedy.API.get_user(883307747305725972)
      {:ok, %Remedy.Schema.User{
        id: 883307747305725972,
        avatar: "973a059282550a9ffaca42e795d8330b",
        username: "Remedy",
        ...
      }}

      iex Remedy.API.get_user(88330774730572597123)
      {:error, {400, 50035, "Invalid Form Body"}}

  """
  @doc since: "0.6.0"
  @unsafe {:get_user, [:user_id]}
  @spec get_user(snowflake) :: {:error, reason} | {:ok, User.t()}
  def get_user(user_id) do
    {:get, "/users/#{user_id}", nil, nil, nil}
    |> request()
    |> shape(User)
  end

  @doc """
  Changes the attributes of the bot.

  ## Options

    - `:username, :string`
    - `:avatar, :string` see: [avatar data](https://discord.com/developers/docs/resources/user#avatar-data)

  ## Examples

      iex> Remedy.API.modify_current_user(avatar: "data:image/jpeg;base64,YXl5IGJieSB1IGx1a2luIDQgc3VtIGZ1az8=")
      {:ok, %Remedy.Schema.User{}}

  """
  @doc since: "0.6.0"
  @unsafe {:modify_bot, [:opts]}
  @spec modify_bot(opts) :: {:error, reason} | {:ok, User.t()}
  def modify_bot(opts) do
    data = %{}
    types = %{avatar: :string, username: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/users/@me", nil, opts[:reason], body}
    |> request()
  end

  @doc """
  Gets a list of guilds the bot is currently in.

  ## Options

    - `:before, Snowflake`
    - `:after, Snowflake`
    - `:limit, :integer, min: 1, max: 100`

  ## Examples

      iex> Remedy.API.list_guilds(limit: 1)
      {:ok, [%Remedy.Schema.Guild{}]}

  """
  def list_guilds(opts) do
    data = %{limit: 50}
    types = %{before: Snowflake, after: Snowflake, limit: :integer}
    keys = Map.keys(types)

    params =
      {data, types}
      |> cast(opts, keys)

    {:get, "/users/@me/guilds", params, opts[:reason], nil}
    |> request()
  end

  @doc """
  Leaves a guild.

  ## Examples

      iex> Remedy.API.leave_guild(a_guild_i_dont_like)
      :ok

      iex> Remedy.API.leave_guild(a_guild_im_not_in)
      :error, {400, 0, "400: Bad Request"}}

  """
  @spec leave_guild(snowflake) :: {:error, reason} | :ok
  def leave_guild(guild_id) do
    {:delete, "/users/@me/guilds/#{guild_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Create a new DM channel with a user.

  ## Examples

      iex> Remedy.API.create_dm(150061853001777154)
      {:ok, %Remedy.Schema.Channel{}}

  """
  def create_dm(user_id) do
    body = %{recipient_id: user_id}

    {:post, "/users/@me/channels", nil, nil, body}
    |> request()
    |> shape(Channel)
  end

  @doc false
  ## Create a group dm
  ##
  ## Only for GameSDK. Not for us
  ## @doc since: "0.6.8"
  @unsafe {:create_group_dm, [:opts]}
  @spec create_group_dm(any) :: {:error, reason} | {:ok, Channel.t()}
  def create_group_dm(opts), do: {:post, "/users/@me/channels", nil, nil, opts} |> request()

  @doc false
  ## Get a list of the bot's user connections
  ##
  ## Useless, bots have no friends :(
  ## @doc since("0.6.8")
  @unsafe {:list_bot_connections, []}
  @spec list_bot_connections() :: {:error, any} | {:ok, any}
  def list_bot_connections do
    {:get, "/users/@me/connections", nil, nil, nil}
    |> request()
  end

  ## Voice
  @doc """
  Gets a list of voice regions.

  ## Examples

      iex> Remedy.API.list_voice_regions()
      {:ok,
      [
        %{
          custom: false,
          deprecated: false,
          id: "us-west",
          name: "US West",
          optimal: false
        }
      ]

  """

  def list_voice_regions do
    {:get, "/voice/regions", nil, nil, nil}
    |> request()
  end

  ######################################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░██╗░░░░░░░██╗░███████╗░██████╗░░██╗░░██╗░░█████╗░░░█████╗░░██╗░░██╗░░██████╗░ ###
  ### ░██║░░██╗░░██║░██╔════╝░██╔══██╗░██║░░██║░██╔══██╗░██╔══██╗░██║░██╔╝░██╔════╝░ ###
  ### ░╚██╗████╗██╔╝░█████╗░░░██████╦╝░███████║░██║░░██║░██║░░██║░█████═╝░░╚█████╗░░ ###
  ### ░░████╔═████║░░██╔══╝░░░██╔══██╗░██╔══██║░██║░░██║░██║░░██║░██╔═██╗░░░╚═══██╗░ ###
  ### ░░╚██╔╝░╚██╔╝░░███████╗░██████╦╝░██║░░██║░╚█████╔╝░╚█████╔╝░██║░╚██╗░██████╔╝░ ###
  ### ░░░╚═╝░░░╚═╝░░░╚══════╝░╚═════╝░░╚═╝░░╚═╝░░╚════╝░░░╚════╝░░╚═╝░░╚═╝░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ######################################################################################

  @spec create_webhook(any) :: none
  @doc """
  Creates a webhook.

  ## Parameters
    - `channel_id` - Id of the channel to send the message to.
    - `args` - Map with the following **required** keys:
      - `name` - Name of the webhook.
      - `avatar` - Base64 128x128 jpeg image for the default avatar.
    - `reason` - An optional reason for the guild audit log.
  """

  def create_webhook(channel_id) do
    {:post, "/channels/#{channel_id}/webhooks"}
    |> request()
  end

  @doc """
  Gets a list of webook for a channel.

  ## Parameters
    - `channel_id` - Channel to get webhooks for.
  """

  def list_channel_webhooks(channel_id) do
    {:get, "/channels/#{channel_id}/webhooks"}
    |> request()
  end

  @doc """
  Gets a list of webooks for a guild.

  ## Parameters
    - `guild_id` - Guild to get webhooks for.
  """

  def list_guild_webhooks(guild_id) do
    {:get, "/guilds/#{guild_id}/webhooks"}
    |> request()
  end

  @doc since: "0.6.0"
  def list_webhooks(guild_id) do
    {:get, "/#{guild_id}/webhooks"}
    |> request()
  end

  @doc """
  Gets a webhook by id.

  ## Parameters
    - `webhook_id` - Id of the webhook to get.
  """

  def get_webhook(webhook_id) do
    {:get, "/webhooks/#{webhook_id}"}
    |> request()
  end

  @doc """
  Gets a webhook by id and token.

  This method is exactly like `get_webhook/1` but does not require
  authentication.

  ## Parameters
    - `webhook_id` - Id of the webhook to get.
    - `webhook_token` - Token of the webhook to get.
  """

  def get_webhooks_with_token(webhook_id, webhook_token) do
    {:get, "/webhooks/#{webhook_id}/#{webhook_token}"}
    |> request()
  end

  @doc """
  Modifies a webhook.

  ## Parameters
    - `webhook_id` - Id of the webhook to modify.
    - `args` - Map with the following *optional* keys:
      - `name` - Name of the webhook.
      - `avatar` - Base64 128x128 jpeg image for the default avatar.
    - `reason` - An optional reason for the guild audit log.
  """

  def modify_webhook(webhook_id) do
    {:patch, "/webhooks/#{webhook_id}"}
    |> request()
  end

  @doc """
  Modifies a webhook with a token.

  This method is exactly like `modify_webhook/1` but does not require
  authentication.

  ## Parameters
    - `webhook_id` - Id of the webhook to modify.
    - `webhook_token` - Token of the webhook to get.
    - `args` - Map with the following *optional* keys:
      - `name` - Name of the webhook.
      - `avatar` - Base64 128x128 jpeg image for the default avatar.
    - `reason` - An optional reason for the guild audit log.
  """
  def modify_webhooks_with_token(webhook_id, webhook_token) do
    {:modify, "/webhooks/#{webhook_id}/#{webhook_token}"}
    |> request()
  end

  @doc """
  Deletes a webhook.

  ## Parameters
    - `webhook_id` - Id of webhook to delete.
    - `reason` - An optional reason for the guild audit log.
  """
  def delete_webhook(webhook_id) do
    {:delete, "/webhooks/#{webhook_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_webhooks_with_token(webhook_id, webhook_token) do
    {:delete, "/webhooks/#{webhook_id}/#{webhook_token}"}
    |> request()
  end

  @doc """
   Executes a webhook.

   ## Parameters
   - `webhook_id` - Id of the webhook to execute.
   - `webhook_token` - Token of the webhook to execute.
   - `args` - Map with the following required keys:
     - `content` - Message content.
     - `file` - File to send.
     - `embeds` - List of embeds to send.
     - `username` - Overrides the default name of the webhook.
     - `avatar_url` - Overrides the default avatar of the webhook.
     - `tts` - Whether the message should be read over text to speech.
   - `wait` - Whether to return an error or not. Defaults to `false`.

   Only one of `content`, `file` or `embeds` should be supplied in the `args` parameter.
  """

  def execute_webhook(webhook_id, webhook_token) do
    {:post, "/webhooks/#{webhook_id}/#{webhook_token}"}
    |> request()
  end

  ## We are not slack
  ## @doc since("0.6.8")
  @doc false
  @unsafe {:execute_slack_webhook, [:webhook_id, :webhook_token]}
  def execute_slack_webhook(webhook_id, webhook_token) do
    {:post, "/webhooks/#{webhook_id}/#{webhook_token}/slack"}
    |> request()
  end

  ## We are not github
  ## @doc since("0.6.8")
  @doc false
  @unsafe {:execute_github_webhook, [:webhook_id, :webhook_token]}
  @spec execute_github_webhook(snowflake, token) :: {:error, reason} | :ok
  def execute_github_webhook(webhook_id, webhook_token) do
    {:post, "/webhooks/#{webhook_id}/#{webhook_token}/github", nil, nil, nil}
    |> request()
  end

  @doc since: "0.6.0"
  @doc route: "/webhooks/:webhook_id/:webhook_token/messages/:message_id"
  def get_message(webhook_id, webhook_token, message_id) do
    {:get, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_message(webhook_id, webhook_token, message_id) do
    {:patch, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_message(webhook_id, webhook_token, message_id) do
    {:delete, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}"}
    |> request()
  end

  ####################################################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░░█████╗░░██████╗░░██████╗░░██╗░░░░░░██╗░░█████╗░░░█████╗░░████████╗░██╗░░█████╗░░███╗░░██╗░ ###
  ### ░██╔══██╗░██╔══██╗░██╔══██╗░██║░░░░░░██║░██╔══██╗░██╔══██╗░╚══██╔══╝░██║░██╔══██╗░████╗░██║░ ###
  ### ░███████║░██████╔╝░██████╔╝░██║░░░░░░██║░██║░░╚═╝░███████║░░░░██║░░░░██║░██║░░██║░██╔██╗██║░ ###
  ### ░██╔══██║░██╔═══╝░░██╔═══╝░░██║░░░░░░██║░██║░░██╗░██╔══██║░░░░██║░░░░██║░██║░░██║░██║╚████║░ ###
  ### ░██║░░██║░██║░░░░░░██║░░░░░░███████╗░██║░╚█████╔╝░██║░░██║░░░░██║░░░░██║░╚█████╔╝░██║░╚███║░ ###
  ### ░╚═╝░░╚═╝░╚═╝░░░░░░╚═╝░░░░░░╚══════╝░╚═╝░░╚════╝░░╚═╝░░╚═╝░░░░╚═╝░░░░╚═╝░░╚════╝░░╚═╝░░╚══╝░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░░█████╗░░░█████╗░░███╗░░░███╗░███╗░░░███╗░░█████╗░░███╗░░██╗░██████╗░░░██████╗░ ###############
  ### ░██╔══██╗░██╔══██╗░████╗░████║░████╗░████║░██╔══██╗░████╗░██║░██╔══██╗░██╔════╝░ ###
  ### ░██║░░╚═╝░██║░░██║░██╔████╔██║░██╔████╔██║░███████║░██╔██╗██║░██║░░██║░╚█████╗░░ ###
  ### ░██║░░██╗░██║░░██║░██║╚██╔╝██║░██║╚██╔╝██║░██╔══██║░██║╚████║░██║░░██║░░╚═══██╗░ ###
  ### ░╚█████╔╝░╚█████╔╝░██║░╚═╝░██║░██║░╚═╝░██║░██║░░██║░██║░╚███║░██████╔╝░██████╔╝░ ###
  ### ░░╚════╝░░░╚════╝░░╚═╝░░░░░╚═╝░╚═╝░░░░░╚═╝░╚═╝░░╚═╝░╚═╝░░╚══╝░╚═════╝░░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ########################################################################################

  @doc """
  Fetch all global commands.

  ## Parameters
  - `application_id`: Application ID for which to search commands.
    If not given, this will be fetched from `Me`.

  ## Return value
  A list of ``ApplicationCommand``s on success. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#applicationcommand

  ## Example

      iex> Remedy.API.get_global_commands
      {:ok, [%{application_id: "455589479713865749"}]}

  """

  def get_global_commands do
    {:get, "/applications/#{bot_id()}/commands", nil, nil, nil}
    |> request()
  end

  @doc """
  Create a new global application command.

  The new command will be available on all guilds in around an hour.
  If you want to test commands, use `create_guild_command/2` instead,
  as commands will become available instantly there.
  If an existing command with the same name exists, it will be overwritten.

  [Read More](https://discord.com/developers/docs/interactions/slash-commands#create-global-application-command)

  ## Parameters
  - `application_id`: Application ID for which to create the command.
    If not given, this will be fetched from `Me`.
  - `command`: Command configuration, see the linked API documentation for reference.

  ## Return value
  The created command. See the official reference:


  ## Example

      iex>  Remedy.API.create_command(%{name: "edit", description: "ed, man! man, ed", options: []})
      {:ok, %Remedy.Schema.Command{}}

  """
  def create_global_command do
    {:post, "/applications/#{bot_id()}/commands"}
    |> request()
  end

  @doc """

  Gets a global application command.

  ## Permissions

  -

  ## Events

  -

  ## Options

  -

  ## Examples

      iex> Remedy.API.get_global_command(good_command_id)
      {:ok, %Command{}}

      iex> Remedy.API.get_global_command(bad_command_id)
      {:error, reason}


  """

  @doc since: "0.6.8"
  @unsafe {:get_global_command, [:command_id]}

  def get_global_command(command_id) do
    {:get, "/applications/#{bot_id()}/commands/#{command_id}"}
    |> request()
  end

  @doc """
  Update an existing global application command.

  > Note: It can take up to one hour to update global commands.

  ## Parameters
  - `application_id`: Application ID for which to edit the command.
    If not given, this will be fetched from `Me`.
  - `command_id`: The current snowflake of the command.
  - `command`: Command configuration, see the linked API documentation for reference.

  ## Return value
  The updated command. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#edit-global-application-command
  """
  def modify_global_command(command_id) do
    {:patch, "/applications/#{bot_id()}/commands/#{command_id}"}
    |> request()
  end

  @doc """
  Delete an existing global application command.

  ## Parameters
  - `application_id`: Application ID for which to create the command.
    If not given, this will be fetched from `Me`.
  - `command_id`: The current snowflake of the command.
  """
  def delete_global_command(command_id) do
    {:delete, "/applications/#{bot_id()}/commands/#{command_id}"}
    |> request()
  end

  @doc """
  Overwrite the existing global application commands.

  This action will:
  - Create any command that was provided and did not already exist
  - Update any command that was provided and already existed if its configuration changed
  - Delete any command that was not provided but existed on Discord's end

  Updates will be available in all guilds after 1 hour.
  Commands that do not already exist will count toward daily application command create limits.

  ## Parameters

  - `commands`: List of command configurations, see the linked API documentation for reference.

  ## Return value
  Updated list of global application commands. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#bulk-overwrite-global-application-commands
  """
  def overwrite_global_commands(opts)

  def overwrite_global_commands(commands) when is_list(commands) do
    body = for c <- commands, into: [], do: shape(c, Command)

    {:put, "/applications/#{bot_id()}/commands", nil, nil, body}
    |> request()
  end

  @doc since: "0.6.0"
  def list_guild_commands(guild_id) do
    {:get, "/applications/#{bot_id()}/guilds/#{guild_id}/commands"}
    |> request()
  end

  @doc since: "0.6.0"
  def create_guild_command(guild_id) do
    body = %{name: "test_command", type: 3}

    {:post, "/applications/#{bot_id()}/guilds/#{guild_id}/commands", nil, nil, body}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_command(guild_id, command_id) do
    {:get, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_guild_command(guild_id, command_id) do
    {:patch, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_guild_command(guild_id, command_id) do
    {:delete, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}"}
    |> request()
  end

  @doc """
  Overwrite the existing guild application commands on the specified guild.

  This action will:
  - Create any command that was provided and did not already exist
  - Update any command that was provided and already existed if its configuration changed
  - Delete any command that was not provided but already exists

  > This is functionally similar to Ecto's cast_assoc

  ## opts

  - `guild_id`: Guild on which to overwrite the commands.
  - `commands`: List of command configurations, see the linked API documentation for reference.

  ## Return value
  Updated list of guild application commands. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#bulk-overwrite-guild-application-commands
  """
  def overwrite_guild_commands(guild_id) do
    body = %{name: "test_command", description: "test_command_description", type: 3}

    {:put, "/applications/#{bot_id()}/guilds/#{guild_id}/commands", nil, nil, [body]}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_command_permissions(guild_id) do
    {:get, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/permissions"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_command_permissions(guild_id, command_id) do
    {:get, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}/permissions"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_command_permissions(guild_id, command_id) do
    {:put, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}/permissions"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_command_permissions(guild_id) do
    {:put, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/permissions"}
    |> request()
  end

  ## Interactions
  @doc """
  Create a response to an interaction received from the gateway.

  ## Parameters
  - `id`: The interaction ID to which the response should be created.
  - `token`: The interaction token.
  - `response`: An [`InteractionResponse`](https://discord.com/developers/docs/interactions/slash-commands#interaction-interaction-response)
    object. See the linked documentation.

  ## Example




  As an alternative to passing the interaction ID and token, the
  original `t:Remedy.Schema.Interaction.t/0` can also be passed
  directly. See `create_interaction_response/1`.
  """
  def create_interaction_response(interaction_id, interaction_token) do
    {:post, "/interactions/#{interaction_id}/#{interaction_token}/callback"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_original_interaction_response(interaction_token) do
    {:get, "/webhooks/#{bot_id()}/#{interaction_token}/messages/@original"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_original_interaction_response(interaction_token) do
    {:patch, "/webhooks/#{bot_id()}/#{interaction_token}/messages/@original"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_original_interaction_response(interaction_token) do
    {:delete, "/webhooks/#{bot_id()}/#{interaction_token}/messages/@original"}
    |> request()
  end

  @doc """
  Create a followup message for an interaction.

  Delegates to ``execute_webhook/3``, see the function for more details.
  """

  def create_followup(interaction_token) do
    {:post, "/webhooks/#{bot_id()}/#{interaction_token}"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_followup(interaction_token, message_id) do
    {:get, "/webhooks/#{bot_id()}/#{interaction_token}/messsages/#{message_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_followup(interaction_token, message_id) do
    body = %{}

    {:patch, "/webhooks/#{bot_id()}/#{interaction_token}/messsages/#{message_id}", nil, nil, body}
    |> request()
  end

  @doc """
  Delete a followup message for an interaction.

  ## Parameters

  - `:token` - Interaction token.
  - `:message_id` - Followup message ID.

  """
  @doc since: "0.6.0"
  @unsafe {:delete_followup, [:interaction_token, :message_id]}
  @spec delete_followup(token, snowflake) :: :ok | {:error, reason}
  def delete_followup(interaction_token, message_id) do
    {:delete, "/webhooks/#{bot_id()}/#{interaction_token}/messsages/#{message_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  #################################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░░██████╗░░░█████╗░░████████╗░███████╗░░██╗░░░░░░░██╗░░█████╗░░██╗░░░██╗░ ###
  ### ░██╔════╝░░██╔══██╗░╚══██╔══╝░██╔════╝░░██║░░██╗░░██║░██╔══██╗░╚██╗░██╔╝░ ###
  ### ░██║░░██╗░░███████║░░░░██║░░░░█████╗░░░░╚██╗████╗██╔╝░███████║░░╚████╔╝░░ ###
  ### ░██║░░╚██╗░██╔══██║░░░░██║░░░░██╔══╝░░░░░████╔═████║░░██╔══██║░░░╚██╔╝░░░ ###
  ### ░╚██████╔╝░██║░░██║░░░░██║░░░░███████╗░░░╚██╔╝░╚██╔╝░░██║░░██║░░░░██║░░░░ ###
  ### ░░╚═════╝░░╚═╝░░╚═╝░░░░╚═╝░░░░╚══════╝░░░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝░░░░╚═╝░░░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  #################################################################################

  @doc false
  ##  Gets a gateway URL.
  ##
  ##  Used to be required for the websocket
  ##  since: "0.6.0"
  @unsafe {:get_gateway, []}
  @spec get_gateway :: {:error, reason} | {:ok, String.t()}
  def get_gateway do
    {:get, "/gateway", nil, nil, nil}
    |> request()
    |> case do
      {:ok, %{url: url}} -> {:ok, url}
      _ -> {:error, "Malformed Payload"}
    end
  end

  @doc false
  ##  Gets a gateway connection object.
  ##
  ##  Manually invoking this function will count towards your connection limit
  ##  since: "0.6.0"
  @unsafe {:get_gateway_bot, []}
  @spec get_gateway_bot :: {:error, reason} | {:ok, map}
  def get_gateway_bot do
    {:get, "/gateway/bot", nil, nil, nil}
    |> request()
  end

  ###########
  ### Private
  ###########

  @doc false
  ## Grab the bots ID from the Cache
  ##
  ## This is automatically applied to all applicable functions.
  @spec bot_id :: Snowflake.t()
  alias Remedy.Cache
  def bot_id, do: Cache.app().id()

  @doc false
  ## Build a request
  ##
  ## request({method, route, params, reason, body})
  ## since: "0.6.0"
  @spec request({any, any, any, any, any}) :: {:error, any} | {:ok, any}
  def request({method, route, params, reason, %{valid?: true} = body}) do
    request({method, route, params, reason, apply_changes(body)})
  end

  def request({method, route, %Changeset{valid?: true} = params, reason, body}) do
    request({method, route, apply_changes(params), reason, body})
  end

  def request({_method, _route, _params, _reason, %Changeset{valid?: false} = bad_changeset}) do
    return_errors(bad_changeset)
  end

  def request({_method, _route, %Changeset{valid?: false} = bad_changeset, _reason, _body}) do
    return_errors(bad_changeset)
  end

  def request({method, route, params, reason, body}) do
    RestRequest.new(method, route, params, reason, body)
    |> Rest.request()
    |> RestResponse.decode()
  end

  ## Early return changeset errors.
  ##
  defp return_errors(bad_changeset) do
    reason =
      traverse_errors(bad_changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

    {:error, reason}
  end

  ## Schema Breakdown
  ##
  ## If a function accepts a full schema. break it down into a keyword list of permitted changes.
  defp filter_schema_into_opts(schema) when is_struct(schema) do
    schema
    |> EctoMorph.deep_filter_by_schema_fields(schema[:__struct__], filter_not_loaded: true)
    |> Morphix.compactiform!()
    |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  ## Generic in/out casting
  ##
  ## Shapes the data to the correct types discarding invalid fields.
  ## Shapes opts according to a list of fields.
  defp shape({:ok, ""}), do: :ok
  defp shape({:error, _return} = error), do: error
  defp shape({:error, _return} = error, _module), do: error

  defp shape({:ok, returns}, module) when is_list(returns),
    do: {:ok, for(r <- returns, into: [], do: shape(r, module))}

  defp shape({:ok, return}, module), do: {:ok, shape(return, module)}

  defp shape(%{} = params, module) when is_atom(module) do
    params
    |> Morphix.stringmorphiform!()
    |> module.changeset()
    |> Ecto.Changeset.apply_changes()
  end

  defp shape(params, fields) do
    Enum.filter(params, fn {k, _v} -> k in fields end)
    |> Enum.into(for(d <- fields, into: %{}, do: {d, nil}))
    |> Morphix.compactiform!()
  end

  ## Unwraps the return tuple
  ##
  ## For @unsafe {:func, [args]} to be delegated to
  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, reason}), do: raise("#{inspect(reason)}")

  ## Custom Ecto Validations
  ##########################

  ## Validate at least one of the parameters is present.
  ##
  defp validate_at_least_one(changeset, fields, opts \\ [])

  defp validate_at_least_one(%{params: params} = changeset, fields, opts)
       when is_map(params)
       when is_list(fields) do
    presence_map = for field <- fields, into: %{}, do: {to_string(field), to_string(field) in Map.keys(params)}

    validations = for field <- fields, into: [], do: {field, {:at_least_one, opts}}
    msg = String.trim_trailing("At least one of #{inspect(fields)} is required.")

    errors =
      presence_map
      |> has_one_of?()
      |> case do
        true ->
          []

        false ->
          for {k, _v} <- presence_map,
              into: [],
              do: {String.to_atom(k), {message(opts, msg), validation: :at_least_one}}
      end

    %{
      changeset
      | validations: validations ++ changeset.validations,
        errors: errors ++ changeset.errors,
        valid?: changeset.valid? and errors == []
    }
  end

  ## Validate at most one of the parameters is present.
  ##
  defp validate_at_most_one(changeset, fields, opts \\ [])

  defp validate_at_most_one(%{params: params} = changeset, fields, opts)
       when is_map(params)
       when is_list(fields) do
    presence_map = for field <- fields, into: %{}, do: {to_string(field), to_string(field) in Map.keys(params)}

    msg = String.trim_trailing("At most one of #{inspect(fields)} is permitted. ")
    validations = for field <- fields, into: [], do: {field, {:at_most_one, opts}}

    errors =
      presence_map
      |> how_many_of()
      |> case do
        0 ->
          []

        1 ->
          []

        2 ->
          for {k, _v} <- presence_map,
              into: [],
              do: {k, {message(opts, msg), validation: :at_least_one}}
      end

    %{
      changeset
      | validations: validations ++ changeset.validations,
        errors: errors ++ changeset.errors,
        valid?: changeset.valid? and errors == []
    }
  end

  defp has_one_of?(presence_map) do
    case Enum.filter(presence_map, fn {_k, v} -> v == true end) do
      [] -> false
      [_ | _] -> true
    end
  end

  defp how_many_of(presence_map) do
    Enum.reduce(presence_map, 0, fn
      {k, true}, acc -> acc + 1
      {k, false}, acc -> acc - 1
    end)
  end

  defp message(opts, key \\ :message, default) do
    Keyword.get(opts, key, default)
  end
end
