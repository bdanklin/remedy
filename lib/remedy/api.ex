defmodule Remedy.API do
  @moduledoc """
  Standard interface for the Discord API.

  The majority of the functions within this module are pulled directly from the Discord API. Some custom implementations are included.

  Some functions are useless in the scope of a bot and are intentionally omitted.

  ## Ratelimits

  Discord imposes rate limits in various capacities. The functions in this module will respect those rate limits where possible. In certain circumstances, discord will impose hidden rate limits to avoid abuse, which you can still hit.

  ## Bang!

  While intentionally undocumented to reduce clutter, all functions can be banged to return or raise.

  ## Audit Log Reason

  Many endpoints accept the `X-Audit-Log-Reason` header to provide a reason for the action. This is a string that is displayed in the audit log, limited to 512 characters.

  Due to Discords API documentation being sketchy, this header is not always accurately documented where it is accepted.

  Reasons for the audit log can be passed to discord via the `reason: "Some Audit Log Reason"` option. Routes that are known to accept this header are marked with the 📒 symbol.

  ## Casting vs Modifying

  Modifying an object will only change the given fields. Whereas casting will overwrite the entire array of objects.

  For example, if you have the following guild:

  ```elixir
  iex> Remedy.API.get_guild!(81384788765712384)
  %Remedy.Schema.Guild{
    id: 81384788765712384,
    name: "Remedy",
    icon: "f817c5adaf96672c94a17de8e944f427",
    ...
  }
  ```
  Calling `modify_guild(81384788765712384, name: "New Remedy Server")` will change the name to "New Remedy Server", but will not change the icon.

  ```elixir
  iex> Remedy.API.modify_guild!(81384788765712384, name: "New Remedy Server")
  %Remedy.Schema.Guild{
    id: 81384788765712384,
    name: "New Remedy Server",
    icon: "f817c5adaf96672c94a17de8e944f427",
    ...
  }
  ```

  Conversely for casting functions, it will perform a create, update, delete in one operation, and then read the resultant. For example, if your guild is set up with the following application commands:

  ```elixir
  iex> Remedy.API.list_commands!(81384788765712384)
  [
    %{name: "foo", description: "Foo the bot"},
    %{name: "bar", description: "Bar the bot"},
    %{name: "ping", description: "Ping the bot"}
  ]
  ```
  Casting the below will overwrite, update, and replace the entire array of commands.

  ```elixir
  iex> commands = [
                    %{name: "foo", description: "Bar the bot"},
                    %{name: "baz", description: "baz the bot"}
  ]
  ...> Remedy.API.cast_commands!(81384788765712384, commands)
  [
    %{name: "foo", description: "Bar the bot"},
    %{name: "baz", description: "baz the bot"}
  ]
  ```
  Matching on the name, commands with a name that already exists will be updated. Names that are not provided will be deleted, and new commands will be created.

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
    Emoji,
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

  @typedoc """
  HTTP Response Code
  """
  @type code :: integer()

  @typedoc """
  Options to be passed to a function
  """
  @type opts :: keyword() | map() | nil

  @typedoc """
  Error returned from the HTTP Adapter
  """
  @type error :: any()

  @typedoc """
  A Discord Snowflake
  """
  @type snowflake :: Remedy.Snowflake.t() | String.t()

  @typedoc """
  Reason for an error
  """
  @type reason :: String.t() | nil

  @typedoc """
  A String Token
  """
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

  #############################################################################
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
  @doc method: "get"
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
  @doc method: "get"
  @doc route: "/channels/:channel_id"
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

  ## Options

  - `:name`  - `:string, min: 2, max: 100`
  - `:position`  - `:integer` - Not contiguous, will be ordered by `:id` if duplicates exist.
  - `:topic`  `:string, min: 0, max: 1024`
  - `:nsfw`  `:boolean, default: false`
  - `:bitrate`  - `:integer, min: 8000, max: 128000`
  - `:user_limit`  - `:integer, min: 1, max: 99, unlimited: 0`
  - `:permission_overwrites`  - `{:array, %Overwrite{}}`
  - `:parent_id`  - category to place the channel under.

  ## Examples

      iex> Remedy.API.modify_channel(41771983423143933, name: "elixir-remedy", topic: "remedy discussion")
      {:ok, %Remedy.Schema.Channel{id: 41771983423143933, name: "elixir-remedy", topic: "remedy discussion"}}


  """

  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_CHANNEL"]
  @doc events: ["CHANNEL_UPDATE"]
  @doc method: "patch"
  @doc route: "/channels/:channel_id"
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

  ## Examples

      iex> Remedy.API.delete_channel(421533712753360896)
      {:ok, %Remedy.Schema.Channel{id: 421533712753360896}}

      iex> Remedy.API.delete_channel(123)
      {:error, reason}

  """
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_CHANNELS"]
  @doc events: ["CHANNEL_DELETE"]
  @doc route: "/channels/:channel_id"
  @doc audit_log: true
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

  ## Options

  - `:before`  - `Snowflake` - Retrieve messages before this message.
  - `:after`  - `Snowflake` - Retrieve messages after this message.
  - `:around`  - `Snowflake` - Retrieve messages around this message.
  - `:limit`  - `:integer, min: 1, max: 100` - The maximum number of messages to retrieve.

  > Only one of `:before`, `:after`, or `:around` may be specified.

  ## Helpers

  - `Remedy.API.list_messages_before/3`
  - `Remedy.API.list_messages_after/3`
  - `Remedy.API.list_messages_around/3`

  ## Examples

      iex> Remedy.API.list_messages(872417560094732331, [{:before, 882781809908256789}, {:limit, 1}])
      {:ok, [%Message{id: 882681855315423292}]}

  """
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/messages"
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

  ## Examples

      iex> Remedy.API.list_messages_before(%{channel_id: 872417560094732331, id: 882781809908256789}, limit: 1)
      {:ok, [%Message{id: 882681855315423292}]}

  """
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/messages"
  @unsafe {:list_messages_before, [:message, :limit]}
  @spec list_messages_before(Message.t(), 1..50) :: {:error, any} | {:ok, list}
  def list_messages_before(%{id: message_id, channel_id: channel_id} = message, limit \\ 50)
      when is_map(message) do
    list_messages(channel_id, [{:before, message_id}, {:limit, limit}])
  end

  @doc """
  List messages after a given message.

  ## Examples

      iex> Remedy.API.list_messages_after(%{channel_id: 872417560094732331, id: 882781809908256789}, limit: 1)
      {:ok, [%Message{id: 882681855315423292}]}


  """
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/messages"
  @unsafe {:list_messages_after, [:message, :limit]}
  @spec list_messages_after(Message.t(), 1..50) :: {:error, any} | {:ok, list}
  def list_messages_after(message, limit \\ 50)

  def list_messages_after(%Message{id: message_id, channel_id: channel_id} = message, limit)
      when is_struct(message, Message) do
    list_messages(channel_id, [{:after, message_id}, {:limit, limit}])
  end

  @doc """
  List messages around a given message.

  ## Examples

      iex> Remedy.API.list_messages_around(%{channel_id: 872417560094732331, id: 882781809908256789}, limit: 1)
      {:ok, [%Message{id: 882681855315423292}]}

  """
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/messages"
  @unsafe {:list_messages_around, [:message, :limit]}
  @spec list_messages_around(Message.t(), 1..50) :: {:error, any} | {:ok, list}
  def list_messages_around(message, limit \\ 50)

  def list_messages_around(%Message{id: message_id, channel_id: channel_id} = message, limit)
      when is_struct(message, Message) do
    list_messages(channel_id, [{:around, message_id}, {:limit, limit}])
  end

  @doc """
  Retrieves a message from a channel.

  ## Examples

      iex> Remedy.API.get_message(872417560094732331, 884355195277025321)
      {:ok, %Remedy.Schema.Message{}}

  """
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/messages/:message_id"
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

  ## Options

  - `:content`  - `:string, max: 2000`
  - `:tts`  - `:boolean`
  - `:embeds`  - `{:array, Embed | :map}`
  - `:allowed_mentions`  - `AllowedMentions | :map`
  - `:message_reference`  - `MessageReference | :map`
  - `:components`  - `{:array, Component | :map}`
  - `:sticker_ids`  - `{:array, Snowflake}`
  - `:attachments`  - `{:array, Attachment}`

  > Note: At least one of the following is required: `:content`, `:file`, `:embed`.

  ## Examples

      iex> {:ok, message} = Remedy.API.create_message(872417560094732331, content: "**Doctest Message** ✅")
      ...> message.content
      "**Doctest Message** ✅"

  """
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "SEND_MESSAGES", "SEND_MESSAGES_TTS"]
  @doc method: "post"
  @doc route: "/channels/:channel_id/messages"
  @doc events: ["MESSAGE_CREATE"]
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

  ## Examples

      iex> Remedy.API.publish_message(message_object)
      {:ok, %Remedy.Schema.Message{}}

  """
  @doc since: "0.6.0"
  @doc permissions: ["SEND_MESSAGES", "MANAGE_MESSAGES"]
  @doc method: "post"
  @doc route: "/channels/:channel_id/messages/publish"
  @spec publish_message(Message.t()) :: {:error, any} | {:ok, any}
  @unsafe {:publish_message, [:message]}
  def publish_message(%Message{channel_id: channel_id, id: id}),
    do: publish_message(channel_id, id)

  @doc """
  Publish a message in a news channel.

  This will propagate a message out to all followers of the channel. This function accepts a channel ID and message ID instead of a message object.

  ## Examples

      iex> Remedy.API.publish_message(872417560094732331, 884355195277025321)
      {:ok, %Remedy.Schema.Message{}}

  """

  @doc since: "0.6.8"
  @doc permissions: ["SEND_MESSAGES", "MANAGE_MESSAGES"]
  @doc method: "post"
  @doc route: "/channels/:channel_id/messages/:message_id/crosspost"
  @spec publish_message(snowflake, snowflake) :: {:error, any} | {:ok, map}
  @unsafe {:publish_message, [:channel_id, :message_id]}
  def publish_message(channel_id, message_id) do
    {:post, "/channels/#{channel_id}/messages/#{message_id}/crosspost", nil, nil, nil}
    |> request()
    |> shape(Message)
  end

  @doc """
  Creates a reaction for a message.

  ## Examples

      iex> Remedy.API.add_reaction(123123123123, 321321321321, %{id: 43819043108, name: "foxbot"})
      :ok

      iex> Remedy.API.add_reaction(123123123123, 321321321321, "\xF0\x9F\x98\x81")
      :ok

  """
  @doc section: :reactions
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY", "ADD_REACTIONS"]
  @doc events: ["MESSAGE_REACTION_ADD"]
  @doc method: "put"
  @doc route: "/channels/:channel_id/messages/:message_id/reactions/:emoji/@me"
  @unsafe {:add_reaction, [:channel_id, :message_id, :emoji]}
  @spec add_reaction(snowflake, snowflake, binary | Emoji.t() | map) :: :ok | {:error, reason}
  def add_reaction(channel_id, message_id, emoji) when is_binary(emoji) do
    {:put, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me", nil, nil, nil}
    |> request()
    |> shape()
  end

  def add_reaction(channel_id, message_id, %{name: name, id: id}) do
    add_reaction(channel_id, message_id, "#{name}:#{id}")
  end

  @doc """
  Creates a reaction for a message.

  Takes a message object instead of a channel ID and message ID.

  ## Examples

      iex> Remedy.API.add_reaction(message_object, %{id: 43819043108, name: "foxbot"})
      :ok

      iex> Remedy.API.add_reaction(message_object, "\xF0\x9F\x98\x81")
      :ok


  """
  @doc section: :reactions
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY", "ADD_REACTIONS"]
  @doc events: ["MESSAGE_REACTION_ADD"]
  @doc method: "put"
  @doc route: "/channels/:channel_id/messages/:message_id/reactions/:emoji/@me"
  @unsafe {:add_reaction, [:message, :emoji]}
  @spec add_reaction(Message.t(), binary | Emoji.t() | map) :: :ok | {:error, reason}
  def add_reaction(message, emoji) do
    add_reaction(message.channel_id, message.id, emoji)
  end

  @doc """
  Deletes a reaction the bot has made for the message.

  ## Examples

      iex> Remedy.API.remove_reaction(channel_id, message_id, 123)
      :ok

  """
  @doc section: :reactions
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY", "ADD_REACTIONS"]
  @doc events: ["MESSAGE_REACTION_REMOVE"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/messages/:message_id/reactions/:emoji/@me"
  @unsafe {:remove_reaction, [:channel_id, :message_id, :emoji]}
  @spec remove_reaction(snowflake, snowflake, term) :: :ok | {:error, reason}
  def remove_reaction(channel_id, message_id, emoji) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Deletes another user's reaction from a message.

  ## Examples

       iex> Remedy.API.remove_reaction(channel_id, message_id, 123, "foxbot")
       :ok

  """
  @doc section: :reactions
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY", "MANAGE_MESSAGES"]
  @doc events: ["MESSAGE_REACTION_REMOVE"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/messages/:message_id/reactions/:emoji/:user_id"
  @spec remove_reaction(snowflake, snowflake, snowflake, any) :: {:error, any} | {:ok, any}
  @unsafe {:remove_reaction, [:channel_id, :message_id, :emoji, :user_id]}
  def remove_reaction(channel_id, message_id, emoji, user_id) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/#{user_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Gets all users who reacted with an emoji.


  """
  @doc section: :reactions
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY", "ADD_REACTIONS"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/messages/:message_id/reactions/:emoji"
  @unsafe {:list_reactions, [:channel_id, :message_id, :emoji]}
  @spec list_reactions(snowflake, snowflake, any) :: {:ok, [User.t()]}
  def list_reactions(channel_id, message_id, emoji) do
    {:get, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}", nil, nil, nil}
    |> request()
    |> shape(User)
  end

  @doc """
  Deletes all reactions from a message.

  ## Examples

      iex> Remedy.API.clear_reactions(893605899128676443, 912815032755191838)
      :ok

  """
  @doc section: :reactions
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY", "MANAGE_MESSAGES"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/messages/:message_id/reactions"
  @doc events: ["MESSAGE_REACTION_REMOVE_ALL"]
  @spec clear_reactions(snowflake, snowflake) :: {:error, reason} | :ok
  @unsafe {:clear_reactions, [:channel_id, :message_id]}
  def clear_reactions(channel_id, message_id) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Deletes all reactions of a given emoji from a message.

  ## Examples

      iex> Remedy.API.clear_reactions(893605899128676443, 912815032755191838, "\xF0\x9F\x98\x81")
      :ok

  """
  @doc section: :reactions
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_MESSAGES"]
  @doc events: ["MESSAGE_REACTION_REMOVE_EMOJI"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/messages/:message_id/reactions/:emoji"
  @unsafe {:clear_reactions, [:channel_id, :message_id, :emoji]}
  @spec clear_reactions(snowflake, snowflake, any) :: {:error, reason} | :ok
  def clear_reactions(channel_id, message_id, emoji) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}", nil, nil, nil}
    |> request()
  end

  @doc """
  Edits a previously sent message in a channel.

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
  @doc permissions: ["VIEW_CHANNEL", "SEND_MESSAGES", "MANAGE_MESSAGES"]
  @doc events: ["MESSAGE_UPDATE"]
  @doc method: "patch"
  @doc route: "/channels/:channel_id/messages/:message_id"
  @doc audit_log: true
  @unsafe {:modify_message, [:channel_id, :message_id, :opts]}
  @spec modify_message(snowflake, snowflake, opts) :: :ok | {:error, reason}
  def modify_message(channel_id, message_id, opts \\ [])

  def modify_message(webhook_id, webhook_token, message_id) when is_snowflake(message_id) do
    modify_message(webhook_id, webhook_token, message_id, [])
  end

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

  ## Examples

      iex> Remedy.API.delete_message(43189401384091, 43189401384091)

  """
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "MANAGE_MESSAGES"]
  @doc events: ["MESSAGE_DELETE"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/messages/:message_id"
  @doc audit_log: true
  @unsafe {:delete_message, [:channel_id, :message_id]}
  @spec delete_message(snowflake, snowflake, opts) :: :ok | {:error, reason}
  def delete_message(channel_id, message_id, opts \\ [])

  def delete_message(webhook_id, webhook_token, message_id) when is_snowflake(message_id) do
    delete_message(webhook_id, webhook_token, message_id, [])
  end

  def delete_message(channel_id, message_id, opts) do
    reason = opts[:reason]

    {:delete, "/channels/#{channel_id}/messages/#{message_id}", nil, reason, nil}
    |> request()
  end

  @doc """
  Deletes multiple messages from a channel.

  This can only be used on guild channels.

  ## Options

  - `:messages`  - `{:array, Snowflake}` - the messages to delete

  ## Examples

      iex> Remedy.API.bulk_delete_messages(43189401384091, [43189401384091, 43189401384092])
      :ok

  """
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_MESSAGES"]
  @doc events: ["MESSAGE_DELETE_BULK"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/messages/bulk-delete"
  @doc audit_log: true
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

  ## Options

    - `:type`  - `:integer, role: 0, member: 1`
    - `:allow`  - `:integer | Permission`
    - `:deny`  - `:integer | Permission`

  > note: If `:allow`, or `:deny` are not explicitly set they will be set to 0.

  ## Examples

      iex> Remedy.API.edit_permissions(893605899128676443, 893605899128676443, type: :role, allow: :read_messages)


  """
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_ROLES"]
  @doc events: ["CHANNEL_PERMISSION_UPDATE"]
  @doc method: "patch"
  @doc route: "/channels/:channel_id/permissions/:overwrite_id"
  @doc audit_log: true
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

  ## Examples

      iex> Remedy.API.list_channel_invites(43189401384091)
      {:ok, [%Remedy.Schema.Invite{}]}

  """
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "MANAGE_CHANNELS"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/invites"
  @unsafe {:list_channel_invites, [:channel_id]}
  @spec list_channel_invites(snowflake) :: {:ok, [Invite.t()]} | {:error, reason}
  def list_channel_invites(channel_id) do
    {:get, "/channels/#{channel_id}/invites", nil, nil, nil}
    |> request()
    |> shape(Invite)
  end

  @doc """
  Creates an invite for a guild channel.

  ## Options

    - `:max_age`  -  `:integer, min: 0, max: 604800, default: 86400` - duration of invite in seconds before expiry, or 0 for never.
    - `:max_uses`  -  `:integer, min: 0, max: 100, default: 0` - number of times the invite can be used, or 0 for unlimited.
    - `:temporary`  - `:boolean, default: false` - Whether the invite should grant temporary membership.
    - `:unique`  - `:boolean, default: false` - 	if true, don't try to reuse a similar invite (useful for creating many unique one time use invites)
    - `:target_type`  - `:integer` - 	the type of target for this voice channel invite.
      - `stream: 1, embedded: 2`
    - `:target_user_id`  - `Snowflake` - 	the id of the user whose stream to display for this invite, required if target_type is 1, the user must be streaming in the channel
    - `:target_application_id`  - `Snowflake`  - 	the id of the embedded application to open for this invite, required if target_type is 2, the application must have the EMBEDDED flag

  ## Target Type

  If the target type is set, the target_user_id or target_application_id fields must be set respective to the target type.

  ## Examples

      iex> Remedy.API.create_channel_invite(41771983423143933)
      {:ok, Remedy.Schema.Invite{}}

      iex> Remedy.API.create_channel_invite(41771983423143933, max_uses: 20)
      {:ok, %Remedy.Schema.Invite{}}

  """
  @doc since: "0.6.0"
  @doc permissions: ["CREATE_INSTANT_INVITE"]
  @doc events: ["CHANNEL_INVITE_CREATE"]
  @doc method: "post"
  @doc route: "/channels/:channel_id/invites"
  @doc audit_log: true
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

  ## Examples

      iex> Remedy.API.delete_channel_permission(41771983423143933, 41771983423143933)
      :ok

  """
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_ROLES"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/permissions/:overwrite_id"
  @doc audit_log: true
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

  > note: channel_id is the news channel. webhook_channel_id is the target channel.

  ## Examples

      iex> Remedy.API.follow_news_channel(41771983423143933, 41771983423143933)
      {:ok, %{}}

  """
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_WEBHOOKS"]
  @doc method: "post"
  @doc route: "/channels/:channel_id/followers"
  @unsafe {:follow_news_channel, [:channel_id, :webhook_channel_id]}
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

  ## Examples

      iex> Remedy.API.start_typing(891925736120791080)
      :ok

      iex> Remedy.API.start_typing(bad_channel_id)
      {:error, {404, 10003, "Unknown Channel"}}

  """
  @doc since: "0.6.8"
  @doc events: ["TYPING_START"]
  @doc method: "post"
  @doc route: "/channels/:channel_id/typing"
  @doc audit_log: false
  @unsafe {:start_typing, [:channel_id]}
  @spec start_typing(snowflake) :: :ok | {:error, reason}
  def start_typing(channel_id) do
    {:post, "/channels/#{channel_id}/typing", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Retrieves all pinned messages from a channel.

  ## Examples

      iex> Remedy.API.get_pinned_messages(43189401384091)
      {ok, %Message{}}

  """
  @doc since: "0.6.0"
  @doc permissions: ["VIEW_CHANNEL", "READ_MESSAGE_HISTORY"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/pins"
  @doc audit_log: false
  @unsafe {:list_pinned_messages, [:channel_id]}
  @spec list_pinned_messages(snowflake) :: {:ok, Message.t()} | {:error, reason}
  def list_pinned_messages(channel_id) do
    {:get, "/channels/#{channel_id}/pins", nil, nil, nil}
    |> request()
    |> shape(Message)
  end

  @doc """
  Pins a message in a channel.

  The max pinned messages for a channel is 50

  ## Examples

      iex> Remedy.API.pin_message(43189401384091, 18743893102394)
      :ok

  """
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_MESSAGES"]
  @doc events: ["MESSAGE_UPDATE", "CHANNEL_PINS_UPDATE"]
  @doc method: "put"
  @doc route: "/channels/:channel_id/pins/:message_id"
  @doc audit_log: true
  @unsafe {:pin_message, [:channel_id, :message_id]}
  @spec pin_message(snowflake, snowflake, opts) :: :ok | {:error, any}
  def pin_message(channel_id, message_id, opts \\ [])

  def pin_message(channel_id, message_id, opts) when is_snowflake(channel_id) and is_snowflake(message_id) do
    reason = opts[:reason]

    {:put, "/channels/#{channel_id}/pins/#{message_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  @doc """
  Unpins a message in a channel.

  ## Examples

      iex> Remedy.API.unpin_message(43189401384091, 18743893102394)
      :ok

  """
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_MESSAGES"]
  @doc events: ["MESSAGE_UPDATE", "CHANNEL_PINS_UPDATE"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/pins/:message_id"
  @doc audit_log: true
  @unsafe {:unpin_message, [:channel_id, :message_id, :opts]}
  @spec unpin_message(snowflake, snowflake, opts) :: :ok | {:error, reason}
  def unpin_message(channel_id, message_id, opts \\ []) do
    reason = opts[:reason]

    {:delete, "/channels/#{channel_id}/pins/#{message_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  #############################################################################
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

  #############################################################################
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

  ## Option

  - `:name`  - `:string, min: 1, max: 100`
  - `:auto_archive_duration`  - `integer: 60, 1440, 4320, 10080`
  - `:rate_limit_per_user`  - `:integer, min: 0, max: 21600` - Message sending cooldown in seconds.

  ## Examples

      iex> Remedy.API.start_thread(43189401384091, "Hello World")
      {:ok, %Message{}}

  """

  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_MESSAGES"]
  @doc events: ["THREAD_CREATE"]
  @doc method: "post"
  @doc route: "/channels/:channel_id/messages/:message_id/threads"
  @doc audit_log: true
  @unsafe {:create_thread, [:channel_id, :message_id, :opts]}
  @spec create_thread(snowflake, snowflake, opts) :: {:ok, Message.t()} | {:error, reason}

  def create_thread(channel_id, message_id, opts) when is_snowflake(channel_id) and is_snowflake(message_id) do
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
  @doc permissions: ["MANAGE_MESSAGES"]
  @doc events: ["THREAD_CREATE"]
  @doc method: "post"
  @doc route: "/channels/:channel_id/threads"
  @doc audit_log: true
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

  ## Examples

      iex> Remedy.API.join_thread(thread_the_bot_is_not_yet_in)
      :ok

      iex> Remedy.API.join_thread(thread_the_bot_is_already_in)
      :ok

      iex> Remedy.API.join_thread(a_category_channel)
      {:error, {400, 50024, "Cannot execute action on this channel type"}}


  """
  @doc since: "0.6.0"
  @doc events: ["THREAD_MEMBERS_UPDATE", "THREAD_CREATE"]
  @doc method: "put"
  @doc route: "/channels/:channel_id/thread-members/@me"
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

  ## Examples

      iex> Remedy.API.add_thread_member(channel_id, user_id)
      :ok

  """
  @doc since: "0.6.0"
  @doc permissions: ["SEND_MESSAGES"]
  @doc events: ["THREAD_MEMBERS_UPDATE"]
  @doc method: "put"
  @doc route: "/channels/:channel_id/thread-members/:user_id"
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

  ## Examples

      iex> Remedy.API.leave_thread(channel_id)
      :ok

  """
  @doc since: "0.6.0"
  @doc events: ["THREAD_MEMBERS_UPDATE"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/thread-members/@me"
  @unsafe {:leave_thread, [:channel_id]}
  @spec leave_thread(snowflake) :: :ok
  def leave_thread(channel_id) do
    {:delete, "/channels/#{channel_id}/thread-members/@me", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Remove a user from a thread.

  Also requires the thread is not archived.

  ## Examples

      iex> Remedy.API.remove_thread_member(channel_id, user_id)
      :ok

  """

  @doc since: "0.6.0"
  @doc events: ["THREAD_MEMBERS_UPDATE"]
  @doc permissions: ["MANAGE_THREADS"]
  @doc method: "delete"
  @doc route: "/channels/:channel_id/thread-members/:user_id"
  @unsafe {:remove_thread_member, [:channel_id, :user_id]}
  @spec remove_thread_member(snowflake, snowflake) :: :ok | {:error, any}
  def remove_thread_member(channel_id, user_id) do
    {:delete, "/channels/#{channel_id}/thread-members/#{user_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  List members of a thread.

  ## Examples

      iex> Remedy.API.list_thread_members(channel_id)
      {:ok, [%User{}, ...]}

  """
  @doc since: "0.6.0"
  @doc permissions: ["GUILD_MEMBERS"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/thread-members"
  @unsafe {:list_thread_members, [:channel_id]}
  @spec list_thread_members(snowflake) :: {:error, reason} | {:ok, [User.t()]}
  def list_thread_members(channel_id) do
    {:get, "/channels/#{channel_id}/thread-members", nil, nil, nil}
    |> request()
    |> shape(User)
  end

  ############################################################################
  ### Deprecated
  @doc false
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

  ############################################################################
  ### Deprecated
  @doc false
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
  @doc method: "get"
  @doc route: "/guilds/:guild_id/threads/active"
  @unsafe {:list_active_guild_threads, [:guild_id]}
  @spec list_active_guild_threads(Remedy.Schema.Guild.t()) :: {:error, reason} | {:ok, [Thread.t()]}
  def list_active_guild_threads(guild_id) do
    {:get, "/guilds/#{guild_id}/threads/active", nil, nil, nil}
    |> request()
    |> shape(Thread)
  end

  @doc """
  List public archived threads in the given channel.

  ## Options

  - `:before`  - `Snowflake`
  - `:limit`  - `:integer`

  ## Examples

      iex> Remedy.API.list_public_archived_threads(channel_id)
      {:ok, [%Thread{}]}

  """
  @doc since: "0.6.0"
  @doc permissions: ["READ_MESSAGE_HISTORY"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/threads/archived/public"
  @unsafe {:list_public_archived_threads, [:channel_id]}
  @spec list_public_archived_threads(snowflake, opts) :: {:error, any} | {:ok, any}
  def list_public_archived_threads(channel_id, opts \\ []) do
    data = %{}
    types = %{before: ISO8601, limit: :integer}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    params =
      {data, types}
      |> cast(params, keys)

    {:get, "/channels/#{channel_id}/threads/archived/public", params, nil, nil}
    |> request()
    |> shape(Thread)
  end

  @doc """
  List private archived threads in the given channel.

  ## Options

  - `:before`  - `Snowflake`
  - `:limit`  - `:integer`

  ## Examples

      iex> Remedy.API.list_public_archived_threads(channel_id)
      {:ok, [%Thread{}]}

  """
  @doc since: "0.6.0"
  @doc permissions: ["READ_MESSAGE_HISTORY", "MANAGE_THREADS"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/threads/archived/private"
  @unsafe {:list_private_archived_threads, [:channel_id]}
  @spec list_private_archived_threads(snowflake, opts) :: {:ok, [Thread.t()]} | {:error, reason}
  def list_private_archived_threads(channel_id, opts \\ []) do
    data = %{}
    types = %{before: ISO8601, limit: :integer}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    params =
      {data, types}
      |> cast(params, keys)

    {:get, "/channels/#{channel_id}/threads/archived/private", params, nil, nil}
    |> request()
    |> shape(Thread)
  end

  @doc """
  List joined private archived threads.

  ## Options

  - `:before`  - `Snowflake`
  - `:limit`  - `:integer`

  ## Examples

      iex> Remedy.API.list_joined_private_archived_threads(channel_id)
      {:ok, [%Thread{}]}

  """
  @doc since: "0.6.0"
  @unsafe {:list_joined_private_archived_threads, [:channel_id]}
  @doc permissions: ["READ_MESSAGE_HISTORY"]
  @doc method: "get"
  @doc route: "/channels/:channel_id/users/@me/threads/archived/private"
  @spec list_joined_private_archived_threads(snowflake, opts) :: {:ok, [Thread.t()]} | {:error, reason}
  def list_joined_private_archived_threads(channel_id, opts \\ []) do
    data = %{}
    types = %{before: ISO8601, limit: :integer}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    params =
      {data, types}
      |> cast(params, keys)

    {:get, "/channels/#{channel_id}/users/@me/threads/archived/private", params, nil, nil}
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

  ## Examples

      iex> Remedy.API.list_emojis(guild_id)
      {:ok, [%Emoji{}]}

      iex> Remedy.API.list_emojis(bad_guild_id)
      {:error, reason}

  """
  @doc section: :emojis
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_EMOJIS"]
  @doc method: "get"
  @doc route: "/guilds/:guild_id/emojis"
  @unsafe {:list_emojis, [:guild_id]}
  @spec list_emojis(snowflake) :: {:error, reason} | {:ok, [Emoji.t()]}
  def list_emojis(guild_id) do
    {:get, "/guilds/#{guild_id}/emojis", nil, nil, nil}
    |> request()
    |> shape(Emoji)
  end

  @doc """
  Gets an emoji for the given guild and emoji ids.

  ## Examples

      iex> Remedy.API.get_emoji(guild_id, emoji_id)
      {:ok, %Emoji{}}

      iex Remedy.API.get_emoji(guild_id, bad_emoji_id)
      {:error, reason}

  """
  @doc section: :emojis
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_EMOJIS"]
  @doc method: "get"
  @doc route: "/guilds/:guild_id/emojis/:emoji_id"
  @unsafe {:get_emoji, [:guild_id, :emoji_id]}
  @spec get_emoji(snowflake, snowflake) :: {:error, reason} | {:ok, Emoji.t()}
  def get_emoji(guild_id, emoji_id) do
    {:get, "/guilds/#{guild_id}/emojis/#{emoji_id}", nil, nil, nil}
    |> request()
    |> shape(Emoji)
  end

  @doc """
  Creates a new emoji for the given guild.

  ## Options

    - `:name`
    - `:image`
    - `:roles`

  `:name` and `:image` are always required.

  ## Examples

      iex> Remedy.API.create_emoji(43189401384091,
      ...> name: "remedy", image: "data:image/png;base64,YXl5IGJieSB1IGx1a2luIDQgc3VtIGZ1az8=", roles: [])

  """
  @doc section: :emojis
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_EMOJIS"]
  @doc events: ["EMOJIS_UPDATE"]
  @doc method: "post"
  @doc route: "/guilds/:guild_id/emojis"
  @doc audit_log: true
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

  ## Options

    - `:name`  - `:string`
    - `:roles`  - `[:role]`
    - `:reason`  - `:string`

  ## Examples

      iex> Remedy.API.modify_emoji(43189401384091, 4314301984301, name: "elixir", roles: [])
      {:ok, %Remedy.Schema.Emoji{}}

  """
  @doc section: :emojis
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_EMOJIS"]
  @doc events: ["EMOJIS_UPDATE"]
  @doc method: "patch"
  @doc route: "/guilds/:guild_id/emojis/:emoji_id"
  @unsafe {:modify_emoji, [:guild_id, :emoji_id, :opts]}
  @spec modify_emoji(snowflake, snowflake, opts) :: {:ok, Emoji.t()}
  def modify_emoji(guild_id, emoji_id, opts \\ []) do
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

  ## Examples

      iex> Remedy.API.delete_emoji(snowflake, snowflake, reason: "Because i felt like it")
      :ok

  """
  @doc section: :emojis
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_EMOJIS"]
  @doc events: ["EMOJIS_UPDATE"]
  @doc method: "delete"
  @doc route: "/guilds/:guild_id/emojis/:emoji_id"
  @doc audit_log: true
  @spec delete_emoji(snowflake, snowflake, opts) :: :ok | {:error, any}
  @unsafe {:delete_emoji, [:guild_id, :emoji_id, :opts]}
  def delete_emoji(guild_id, emoji_id, opts \\ []) do
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
  - `:template`  - `:string`

  > If `:template` is provided, the following. All options except `:name`, and `:icon` are ignored.

  > When using the `:roles` parameter, the first member of the array is used to change properties of the guild's `@everyone` role. If you are trying to bootstrap a guild with additional roles, keep this in mind.

  > When using the `:roles` parameter, the required id field within each role object is an integer placeholder, and will be replaced by the API upon consumption. Its purpose is to allow you to overwrite a role's permissions in a channel when also passing in channels with the channels array.

  > When using the `:channels` parameter, the `:position` field is ignored, and none of the default channels are created.

  > When using the `:channels` parameter, the id field within each channel object may be set to an integer placeholder, and will be replaced by the API upon consumption. Its purpose is to allow you to create `:GUILD_CATEGORY` channels by setting the `:parent_id` field on any children to the category's id field. Category channels must be listed before any children.

  ## Examples

      iex> Remedy.API.create_guild(name: "Test Server For Testing")
      {:ok, %Guild{}}

  """
  @doc since: "0.6.0"
  @doc events: ["GUILD_CREATE"]
  @doc method: "post"
  @doc route: "/guilds"
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
      public_updates_channel_id: Snowflake,
      template: :string
    }

    body =
      {data, types}
      |> cast(params, Map.keys(types))
      |> validate_required([:name])
      |> validate_length(:name, min: 2, max: 100)

    case Map.has_key?(params, :template) do
      true ->
        create_guild_from_template(params.template, name: params.name, icon: params.icon)

      false ->
        {:post, "/guilds", nil, nil, body}
        |> request()
        |> shape(Guild)
    end
  end

  @doc """
  Gets a guild.

  ## Examples

      iex> Remedy.API.get_guild(81384788765712384)
      {:ok, %Remedy.Schema.Guild{id: 81384788765712384}}

  """
  @doc since: "0.6.0"
  @doc method: "get"
  @doc route: "/guilds/:guild_id"
  @unsafe {:get_guild, [:guild_id]}
  @spec get_guild(snowflake) :: {:error, reason} | {:ok, Guild.t()}
  def get_guild(guild_id) do
    {:get, "/guilds/#{guild_id}", nil, nil, nil}
    |> request()
  end

  @doc """
  Modifies a guild's settings.

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
  @doc since: "0.6.0"
  @doc method: "patch"
  @doc route: "/guilds/:guild_id"
  @doc audit_log: true
  @doc events: ["GUILD_UPDATE"]
  @doc permissions: ["MANAGE_GUILD"]
  @unsafe {:modify_guild, [:guild_id, :opts]}
  @spec modify_guild(snowflake, opts) :: {:error, reason} | {:ok, Guild.t()}
  def modify_guild(guild_id, opts \\ []) do
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

    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_length(:name, min: 2, max: 100)
      |> validate_inclusion(:verification_level, [0, 1, 2, 3, 4])
      |> validate_inclusion(:default_message_notifications, [0, 1])
      |> validate_inclusion(:explicit_content_filter, [0, 1, 2])

    {:patch, "/guilds/#{guild_id}", nil, reason, body}
    |> request()
    |> shape(Guild)
  end

  @doc """
  Deletes a guild.

  > This endpoint requires that the bot created the guild.

  ## Examples

      iex> Remedy.API.delete_guild(618432108653707274)
      {:error, {403, 50001, "Missing Access"}}

      iex> Remedy.API.delete_guild(618432108653707274)
      {:error, {403, 50001, "Missing Access"}}

  """

  @doc events: ["GUILD_DELETE"]
  @doc method: "delete"
  @doc route: "/guilds/:guild_id"
  @unsafe {:delete_guild, [:guild_id]}
  @spec delete_guild(snowflake) :: {:error, reason} | :ok
  def delete_guild(guild_id) do
    {:delete, "/guilds/#{guild_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  List guild channels.

  Does not include threads

  ## Examples

      iex> Remedy.API.list_channels(81384788765712384)
      {:ok, [%Remedy.Schema.Channel{guild_id: 81384788765712384}]}

  """
  @doc since: "0.6.0"
  @doc method: "get"
  @doc route: "/guilds/:guild_id/channels"
  @unsafe {:list_channels, [:guild_id]}
  @spec list_channels(snowflake) :: {:error, reason} | {:ok, [Channel.t()]}
  def list_channels(guild_id) do
    {:get, "/guilds/#{guild_id}/channels", nil, nil, nil}
    |> request()
    |> shape(Channel)
  end

  @doc """
  Creates a channel for a guild.

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
  @doc permissions: ["MANAGE_CHANNELS"]
  @doc events: ["CHANNEL_CREATE"]
  @doc method: "post"
  @doc route: "/guilds/:guild_id/channels"
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

  ## Examples

      iex> Remedy.API.modify_channel_positions(279093381723062272, [%{id: 351500354581692420, position: 2}])
      {:ok}

      iex> Remedy.API.modify_channel_positions(279093381723062272, [%{id: 351500354581692420, position: 2}])
      {:ok}

  """
  @doc since: "0.6.8"
  @doc permissions: ["MANAGE_CHANNELS"]
  @doc events: ["CHANNEL_UPDATE"]
  @doc method: "patch"
  @doc route: "/guilds/:guild_id/channels"
  @doc audit_log: true
  @unsafe {:modify_channel_positions, [:guild_id, :opts]}
  @spec modify_channel_positions(snowflake, opts) :: {:error, any} | {:ok, any}
  def modify_channel_positions(guild_id, opts) do
    data = %{}
    types = %{positions: {:array, :map}}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/guilds/#{guild_id}/channels", nil, reason, body}
    |> request()
  end

  @doc """
  Gets a guild member.

  ## Examples

      iex> Remedy.API.get_member(4019283754613, 184937267485)
      {:ok, %Remedy.Schema.Member{guild_id: 4019283754613, user_id: 184937267485}}

  """
  @doc since: "0.6.0"
  @doc method: "get"
  @doc route: "/guilds/:guild_id/members/:user_id"
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
      {:ok, [%Remedy.Schema.Member{user_id: 184937267485}]}

  """
  @doc since: "0.6.8"
  @doc method: "get"
  @doc route: "/guilds/:guild_id/members"
  @unsafe {:list_members, [:guild_id, :opts]}
  @spec list_members(snowflake, opts) :: {:error, reason} | {:ok, [Member.t()]}
  def list_members(guild_id, opts) do
    data = %{limit: 1, after: 0}
    types = %{limit: :integer, after: Snowflake}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    params =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:limit, greater_than: 0, less_than_or_equal_to: 1000)

    {:get, "/guilds/#{guild_id}/members", params, nil, nil}
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
  @doc method: "get"
  @doc route: "/guilds/:guild_id/members/search"
  @unsafe {:search_members, [:guild_id, :opts]}
  @spec search_members(snowflake, opts) :: {:error, reason} | {:ok, [GuildMember.t()]}
  def search_members(guild_id, opts) do
    data = %{limit: 1}
    types = %{limit: :integer, query: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    params =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:limit, greater_than: 0, less_than_or_equal_to: 1000)

    {:get, "/guilds/#{guild_id}/members/search", params, nil, nil}
    |> request()
  end

  ############################################################################
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

  ## Options

  - `:nick`  - `:string` - value to set users nickname to
  - `:roles`  - `{:array, Snowflake}` - of role ids the member is assigned
  - `:mute`  -  `:boolean` - if the user is muted
  - `:deaf`  - `:boolean` - if the user is deafened
  - `:channel_id`  - `Snowflake` - id of channel to move user to (if they are connected to voice)

  ## Examples

      iex> Remedy.API.modify_member(41771983423143937, 637162356451, nick: "Remedy")
      :ok

  """
  @doc since: "0.6.0"
  @doc audit_log: true
  @doc permissions: [:MANAGE_NICKNAMES, :MANAGE_ROLES, :MUTE_MEMBERS, :DEAFEN_MEMBERS, :MOVE_MEMBERS]
  @doc events: :MEMBER_UPDATE
  @doc method: "patch"
  @doc route: "/guilds/:guild_id/members/:user_id"
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

  ## Options

    - `:nick`  - `:string` - value to set bots nickname in the guild

  ## Examples

      iex> Remedy.API.modify_bot(41771983423143937, nick: "Remedy")
      {:ok, %{nick: "Remedy"}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:CHANGE_NICKNAME]
  @doc events: :GUILD_MEMBER_UPDATE
  @doc method: "patch"
  @doc audit_log: true
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

  ## Examples

      iex> Remedy.API.add_role(41771983423143937, 637162356451, 431849301)
      {:ok, %{roles: [431849301]}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_ROLES]
  @doc events: :GUILD_MEMBER_UPDATE
  @doc audit_log: true
  @doc method: "PUT"
  @doc route: "guilds/:guild_id/members/:user_id/roles/:role_id"
  @unsafe {:add_role, [:guild_id, :user_id, :role_id, :opts]}
  @spec add_role(snowflake, snowflake, snowflake, opts) :: {:error, reason} | {:ok, Member.t()}
  def add_role(guild_id, user_id, role_id, opts) do
    reason = opts[:reason]

    {:put, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", nil, reason, nil}
    |> request()
  end

  @doc """
  Removes a role from a member.

  ## Examples

      iex> Remedy.API.remove_role(41771983423143937, 637162356451, 431849301)
      :ok

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_ROLES]
  @doc events: :GUILD_MEMBER_UPDATE
  @doc audit_log: true
  @doc method: "DELETE"
  @doc route: "guilds/:guild_id/members/:user_id/roles/:role_id"
  @unsafe {:remove_role, [:guild_id, :user_id, :role_id, :opts]}
  @spec remove_role(snowflake, snowflake, snowflake, opts) :: {:error, reason} | :ok
  def remove_role(guild_id, user_id, role_id, opts \\ []) do
    reason = opts[:reason]

    {:delete, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", nil, reason, nil}
    |> request()
  end

  @doc """
  Removes a member from a guild.

  ## Examples

      iex> Remedy.API.remove_member(1453827904102291, 18739485766253)
      :ok

  """
  @doc since: "0.6.8"
  @doc permissions: [:KICK_MEMBERS]
  @doc events: :GUILD_MEMBER_REMOVE
  @doc audit_log: true
  @doc method: "DELETE"
  @doc route: "guilds/:guild_id/members/:user_id"
  @unsafe {:remove_member, [:guild_id, :user_id, :opts]}
  @spec remove_member(snowflake, snowflake, opts) :: {:error, reason} | :ok
  def remove_member(guild_id, user_id, opts \\ []) do
    reason = opts[:reason]

    {:delete, "/guilds/#{guild_id}/members/#{user_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  @doc """
  Gets a list of users banned for a guild id.

  ## Examples

      iex> Remedy.API.get_bans(41771983423143937)
      {:ok, [{
        user: {
          id: 18739485766253,
          username: "Remedy",
          discriminator: "0000",
          avatar: "a_url",
          bot: false
        },
        reason: "Spamming"
      }]}

  """
  @doc since: "0.6.8"
  @doc permissions: [:BAN_MEMBERS]
  @doc method: "get"
  @doc route: "guilds/:guild_id/bans"
  @unsafe {:list_bans, [:guild_id]}
  @spec list_bans(snowflake) :: {:error, reason} | {:ok, [Ban.t()]}
  def list_bans(guild_id) do
    {:get, "/guilds/#{guild_id}/bans", nil, nil, nil}
    |> request()
    |> shape(Ban)
  end

  @doc """
  Gets a ban for a user and guild id.

  ## Examples

      iex> Remedy.API.get_ban(41771983423143937, 18739485766253)
      {:ok, %{
        user: %{
          id: 18739485766253,
          username: "Remedy",
          discriminator: "0000",
          avatar: "a_url",
          bot: false
        },
        reason: "Spamming"
      }}

  """
  @doc since: "0.6.8"
  @doc permissions: [:BAN_MEMBERS]
  @doc method: "get"
  @doc route: "guilds/:guild_id/bans/:user_id"
  @unsafe {:get_ban, [:guild_id, :user_id]}
  @spec get_ban(snowflake, snowflake) :: {:error, reason} | {:ok, Ban.t()}
  def get_ban(guild_id, user_id) do
    {:get, "/guilds/#{guild_id}/bans/#{user_id}", nil, nil, nil}
    |> request()
    |> shape(Ban)
  end

  @doc """
  Bans a user from a guild.

  ## Examples

      iex> Remedy.API.ban_user(41771983423143937, 18739485766253, reason: "Spamming", delete_message_days: 7)
      :ok

  """
  @doc since: "0.6.8"
  @doc permissions: [:BAN_MEMBERS]
  @doc events: :GUILD_BAN_ADD
  @doc audit_log: true
  @doc method: "PUT"
  @doc route: "guilds/:guild_id/bans/:user_id"
  @unsafe {:ban_user, [:guild_id, :user_id, :opts]}
  @spec ban_user(snowflake, snowflake, opts) :: {:error, reason} | :ok
  def ban_user(guild_id, user_id, opts \\ []) do
    data = %{}
    types = %{delete_message_days: :integer}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})
    reason = opts[:reason]

    params =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:delete_message_days, less_than_or_equal_to: 7, greater_than_or_equal_to: 0)

    {:put, "/guilds/#{guild_id}/bans/#{user_id}", params, reason, nil}
    |> request()
    |> shape()
  end

  @doc """
  Removes a ban for a user.

  ## Examples

      iex> Remedy.API.remove_guild_ban(guild_id, user_id)
      :ok

  """
  @doc since: "0.6.8"
  @doc permissions: [:BAN_MEMBERS]
  @doc events: :GUILD_BAN_REMOVE
  @doc audit_log: true
  @doc method: "DELETE"
  @doc route: "guilds/:guild_id/bans/:user_id"
  @unsafe {:unban_user, [:guild_id, :user_id, :opts]}
  @spec unban_user(snowflake, snowflake, opts) :: :ok | {:error, reason}
  def unban_user(guild_id, user_id, opts \\ []) do
    reason = opts[:reason]

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
  @doc method: "get"
  @doc route: "guilds/:guild_id/roles"
  @unsafe {:list_roles, [:guild_id]}
  @spec list_roles(snowflake) :: {:ok, [Role.t()]} | {:error, reason}
  def list_roles(guild_id) do
    {:get, "/guilds/#{guild_id}/roles", nil, nil, nil}
    |> request()
    |> shape(Role)
  end

  @doc """
  Creates a guild role.

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
  @doc permissions: [:MANAGE_ROLES]
  @doc events: :GUILD_ROLE_CREATE
  @doc audit_log: true
  @doc method: "POST"
  @doc route: "guilds/:guild_id/roles"
  @unsafe {:create_role, [:guild_id, :opts]}
  @spec create_role(snowflake, opts) :: {:ok, Role.t()} | {:error, reason}
  def create_role(guild_id, opts \\ []) do
    data = %{name: "new role", permissions: 0, color: 0, hoist: false, mentionable: false}
    types = %{name: :string, permissions: Permission, color: :integer, hoist: :boolean, mentionable: :boolean}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:color, less_than_or_equal_to: 16_777_215, greater_than_or_equal_to: 0)

    {:post, "/guilds/#{guild_id}/roles", nil, reason, body}
    |> request()
    |> shape(Role)
  end

  @doc """
  Reorders a guild's roles.

  ## Examples

      iex> Remedy.API.modify_role_positions(41771983423143937, [%{id: 41771983423143936, position: 2}])
      {:ok, [%Remedy.Schema.Role{}]}

  """
  @doc permissions: [:MANAGE_ROLES]
  @doc events: :GUILD_ROLE_UPDATE
  @doc audit_log: true
  @doc method: "PATCH"
  @doc route: "guilds/:guild_id/roles"
  @unsafe {:modify_role_positions, [:guild_id, :opts]}
  @spec modify_role_positions(snowflake, opts) :: {:ok, [Role.t()]} | {:error, reason}
  def modify_role_positions(guild_id, opts \\ []) do
    data = %{}
    types = %{positions: [%{id: :snowflake, position: :integer}]}
    keys = Map.keys(types)
    params = Enum.into(data, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:color, less_than_or_equal_to: 16_777_215, greater_than_or_equal_to: 0)

    {:patch, "/guilds/#{guild_id}/roles", nil, reason, body}
    |> request()
    |> shape(Role)
  end

  @doc """
  Modifies a guild role.

  ## Options

    - `:name` (string) - name of the role
    - `:permissions` (integer) - bitwise of the enabled/disabled permissions
    - `:color` (integer) - RGB color value (default: 0)
    - `:hoist` (boolean) - whether the role should be displayed separately in the sidebar
    - `:mentionable` (boolean) - whether the role should be mentionable

  ## Examples

      iex> Remedy.API.modify_guild_role(41771983423143937, 392817238471936, hoist: false, name: "foo-bar")

  """
  @doc since: "0.6.0"
  @doc permissions: [:MANAGE_ROLES]
  @doc events: :GUILD_ROLE_UPDATE
  @doc audit_log: true
  @doc method: "PATCH"
  @doc route: "guilds/:guild_id/roles/:role_id"
  @unsafe {:modify_role, [:guild_id, :role_id, :opts]}
  @spec modify_role(snowflake, snowflake, opts) :: {:ok, Role.t()} | {:error, reason}
  def modify_role(guild_id, role_id, opts \\ []) do
    data = %{}
    types = %{name: :string, permissions: Permission, color: :integer, hoist: :boolean, mentionable: :boolean}
    keys = Map.keys(types)
    params = Enum.into(data, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:color, less_than_or_equal_to: 16_777_215, greater_than_or_equal_to: 0)

    {:patch, "/guilds/#{guild_id}/roles/#{role_id}", nil, reason, body}
    |> request()
    |> shape(Role)
  end

  @doc """
  Deletes a role from a guild.

  ## Examples

      iex> Remedy.API.delete_guild_role(41771983423143937, 392817238471936)

  """
  @doc since: "0.6.0"
  @doc permissions: [:MANAGE_ROLES]
  @doc events: :GUILD_ROLE_DELETE
  @doc audit_log: true
  @doc method: "DELETE"
  @doc route: "guilds/:guild_id/roles/:role_id"
  @unsafe {:delete_role, [:guild_id, :role_id, :opts]}
  @spec delete_role(snowflake, snowflake, opts) :: :ok | {:error, reason}
  def delete_role(guild_id, role_id, opts \\ []) do
    reason = opts[:reason]

    {:delete, "/guilds/#{guild_id}/roles/#{role_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  @doc """
  Gets the number of members that would be removed in a prune given `days`.

  ## Options

  - `:days`  - `:integer, min: 1, max: 30`
  - `:include_roles` - `:string` - comma delimited list of role IDs to include in the count

  ## Examples

      iex> Remedy.API.get_guild_prune_count(81384788765712384, 1)
      {:ok, %{pruned: 0}}

  """
  @doc since: "0.6.0"
  @doc permissions: [:KICK_MEMBERS]
  @doc audit_log: true
  @doc method: "GET"
  @doc route: "guilds/:guild_id/prune"
  @unsafe {:get_prune_count, [:guild_id, :opts]}
  @spec get_prune_count(snowflake, opts) :: {:ok, %{pruned: integer}} | {:error, reason}
  def get_prune_count(guild_id, opts \\ []) do
    data = %{}
    types = %{days: :integer, include_roles: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    params =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:days, less_than_or_equal_to: 30, greater_than_or_equal_to: 1)

    {:get, "/guilds/#{guild_id}/prune", params, nil, nil}
    |> request()
  end

  @doc """
  Begins a guild prune to prune members within `days`.

  ## Options

  - `:days`  - `:integer, min: 1, max: 30`
  - `:include_roles` - `{:array, Snowflake}` - array of role IDs to include in the count
  - `:compute_prune_count` - `:boolean` - whether to compute the prune count

  ## Examples

      iex> Remedy.API.begin_guild_prune(81384788765712384, 1)
      {:ok, %{pruned: 0}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:KICK_MEMBERS]
  @doc audit_log: true
  @doc method: "POST"
  @doc route: "guilds/:guild_id/prune"
  @unsafe {:prune_guild, [:guild_id, :opts]}
  @spec prune_guild(snowflake, opts) :: {:ok, any} | {:error, reason}
  def prune_guild(guild_id, opts \\ []) do
    data = %{}
    types = %{days: :integer, include_roles: {:array, Snowflake}, compute_prune_count: :boolean}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_number(:days, less_than_or_equal_to: 30, greater_than_or_equal_to: 1)

    {:post, "/guilds/#{guild_id}/prune", nil, reason, body}
    |> request()
    |> shape()
  end

  @doc """
  Gets a list of voice regions for the guild.

  > Unlike `f:list_voice_regions/0` this returns VIP servers when the guild is VIP-enabled.

  ## Examples

      iex> Remedy.API.get_guild_voice_regions(81384788765712384)
      {:ok, [
        %{id: "vip-us-east", name: "VIP US East", vip: true},
        %{id: "vip-us-west", name: "VIP US West", vip: true}
        ]
      }

  """
  @doc since: "0.6.8"
  @doc method: "GET"
  @doc route: "guilds/:guild_id/regions"
  @unsafe {:list_voice_regions, [:guild_id]}
  @spec list_voice_regions(snowflake) :: {:ok, any} | {:error, reason}
  def list_voice_regions(guild_id) do
    {:get, "/guilds/#{guild_id}/regions", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Gets a list of invites for a guild.

  ## Examples

      iex> Remedy.API.get_guild_invites(81384788765712384)
      {:ok, [%Remedy.Schema.Invite{}]}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "GET"
  @doc route: "guilds/:guild_id/invites"
  @unsafe {:list_guild_invites, [:guild_id]}
  @spec list_guild_invites(snowflake) :: {:ok, any} | {:error, reason}
  def list_guild_invites(guild_id) do
    {:get, "/guilds/#{guild_id}/invites", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  List a guilds integerations.

  ## Examples

      iex> Remedy.API.list_guild_integrations(81384788765712384)
      {:ok, [%Remedy.Schema.Integration{}]}

  """
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "GET"
  @doc route: "guilds/:guild_id/integrations"
  @unsafe {:list_integrations, [:guild_id]}
  @spec list_integrations(snowflake) :: {:ok, [Integration.t()]} | {:error, reason}
  def list_integrations(guild_id) do
    {:get, "/guilds/#{guild_id}/integrations", nil, nil, nil}
    |> request()
    |> shape(Integration)
  end

  @doc """
  Deletes a guild integeration.

  Delete the attached integration object for the guild. Deletes any associated webhooks and kicks the associated bot if there is one.

  ## Examples

      iex> Remedy.API.delete_guild_integration(81384788765712384, 1)
      :ok

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc events: [:GUILD_INTEGRATIONS_UPDATE]
  @doc method: "DELETE"
  @doc route: "guilds/:guild_id/integrations/:integration_id"
  @unsafe {:remove_integration, [:guild_id, :integration_id, :opts]}
  @spec remove_integration(snowflake, snowflake, opts) :: {:ok, any} | {:error, reason}
  def remove_integration(guild_id, integration_id, opts) do
    reason = opts[:reason]

    {:delete, "/guilds/#{guild_id}/integrations/#{integration_id}", nil, reason, nil}
    |> request()
    |> shape()
  end

  @doc """
  Gets a guilds widget settings.

  ## Examples

      iex> Remedy.API.get_guild_widget_settings(81384788765712384)
      {:ok, %Remedy.Schema.WidgetSettings{}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "get"
  @doc route: "guilds/:guild_id/integrations/:integration_id/sync"
  @unsafe {:get_guild_widget_settings, [:guild_id]}
  @spec get_widget_settings(snowflake) :: {:ok, any} | {:error, reason}
  def get_widget_settings(guild_id) do
    {:get, "/guilds/#{guild_id}/widget", nil, nil, nil}
    |> request()
  end

  @doc """
  Sets a guilds widget.

  ## Examples

      iex> Remedy.API.get_widget(81384788765712384)
      {:ok, %Remedy.Schema.Widget{}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "GET"
  @doc route: "guilds/:guild_id/widget.json"
  @unsafe {:get_widget, [:guild_id]}
  @spec get_widget(snowflake) :: {:ok, any} | {:error, reason}
  def get_widget(guild_id) do
    {:get, "/guilds/#{guild_id}/widget.json", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Get the vanity url for a guild.

  ## Examples

      iex> Remedy.API.get_guild_vanity_url(81384788765712384)
      {:ok, "https://discord.gg/abcdef"}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "GET"
  @doc route: "guilds/:guild_id/vanity_url"
  @unsafe {:get_guild_vanity_url, [:guild_id]}
  @spec get_url(snowflake) :: {:ok, any} | {:error, reason}
  def get_url(guild_id) do
    {:get, "/guilds/#{guild_id}/vanity-url", nil, nil, nil}
    |> request()
  end

  @doc """
  Gets a guilds widget image.

  ## Options

  - `:style`  - `:string` - The style of the image.

  ## Styles

  - shield, shield style widget with Discord icon and guild members online count \n
  ![`shield`](https://discord.com/api/guilds/81384788765712384/widget.png?style=shield)

  - banner1, large image with guild icon, name and online count. "POWERED BY DISCORD" as the footer of the widget \n
  ![`banner1`](https://discord.com/api/guilds/81384788765712384/widget.png?style=banner1)

  - banner2, smaller widget style with guild icon, name and online count. Split on the right with Discord logo \n
  ![`banner2`](https://discord.com/api/guilds/81384788765712384/widget.png?style=banner2)

  - banner3, large image with guild icon, name and online count. In the footer, Discord logo on the left and "Chat Now" on the right \n
  ![`banner3`](https://discord.com/api/guilds/81384788765712384/widget.png?style=banner3)

  - banner4,large Discord logo at the top of the widget. Guild icon, name and online count in the middle portion of the widget and a "JOIN MY SERVER" button at the bottom \n
  ![`banner4`](https://discord.com/api/guilds/81384788765712384/widget.png?style=banner4)

  ## Examples

      iex> Remedy.API.get_guild_widget_image(81384788765712384, style: "banner2")
      {:ok, "https://discord.com/api/guilds/81384788765712384/widget.png?style=banner2"}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "GET"
  @doc route: "guilds/:guild_id/widget.png"
  @unsafe {:get_widget_image, [:guild_id, :opts]}
  def get_widget_image(guild_id, opts \\ []) do
    data = %{}
    types = %{style: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    params =
      {data, types}
      |> cast(params, keys)
      |> validate_inclusion(:style, ["shield", "banner1", "banner2", "banner3", "banner4"])

    {:get, "/guilds/#{guild_id}/widget.png", params, nil, nil}
    |> request()
  end

  @doc """
  Gets a welcome screen for a guild.

  ## Examples

      iex> Remedy.API.get_guild_welcome_screen(81384788765712384)
      {:ok, %Remedy.Schema.GuildWelcomeScreen{}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "GET"
  @doc route: "guilds/:guild_id/welcome-screen"
  @unsafe {:get_welcome, [:guild_id]}
  @spec get_welcome(snowflake) :: {:ok, any} | {:error, reason}
  def get_welcome(guild_id) do
    {:get, "/guilds/#{guild_id}/welcome-screen", nil, nil, nil}
    |> request()
  end

  @doc """
  Modify a guild welcome screen.

  ## Options

  - `:enabled`  - `:boolean` - Whether the welcome screen is enabled.
  - `:welcome_channels`  - `{:array, %WelcomeScreenChannel{}}` - 	channels linked in the welcome screen and their display options.
  - `:description`  - `:string` - The server description to show in the welcome screen.

  ## Examples

      iex> Remedy.API.modify_welcome(
      ...> 81384788765712384,
      ...> enabled: true,
      ...> welcome_channels: [
      ...> {channel_id: 81384788765712384, message: "Welcome to the server!", enabled: true}],
      ...> description: "This is a test server")
      {:ok, %Remedy.Schema.GuildWelcomeScreen{}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc audit_log: true
  @doc method: "PATCH"
  @doc route: "guilds/:guild_id/welcome-screen"
  @unsafe {:modify_welcome, [:guild_id, :opts]}
  def modify_welcome(guild_id, opts \\ []) do
    data = %{}
    types = %{enabled: :boolean, welcome_channels: {:array, WelcomeScreenChannel}, description: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/guilds/#{guild_id}/welcome-screen", nil, reason, body}
    |> request()
  end

  @doc """
  Modify the bots voice state.

  ## Options

  - `:channel_id`  - `:snowflake` - The id of the channel the user is currently in.
  - `:suppress`  - `:boolean` - Toggles the user's suppress state
  - `:request_to_speak_timestamp`  - `ISO8601` - The time at which the user requested to speak.

  > `:channel_id` must currently point to a stage channel.
  > current user must already have joined `:channel_id`.
  > You must have the `:MUTE_MEMBERS` permission to unsuppress yourself. You can always suppress yourself.
  > You must have the `:REQUEST_TO_SPEAK` permission to request to speak. You can always clear your own request to speak.
  > You are able to set `:request_to_speak_timestamp` to any present or future time.

  ## Examples

        iex> Remedy.API.modify_self_voice_state(
        ...> channel_id: 81384788765712384,
        ...> suppress: true)
        {:ok, %Remedy.Schema.VoiceState{}}

  """

  @doc since: "0.6.8"
  @doc permissions: [:MUTE_MEMBERS, :REQUEST_TO_SPEAK]
  @doc events: [:VOICE_STATE_UPDATE]
  @doc method: "PATCH"
  @doc route: "/guilds/:guild_id/voice-states/@me"
  @unsafe {:modify_bot_voice, [:guild_id, :opts]}
  @spec modify_bot_voice(snowflake, opts) :: {:ok, any} | {:error, reason}
  def modify_bot_voice(guild_id, opts \\ []) do
    data = %{}
    types = %{channel_id: Snowflake, suppress: :boolean, request_to_speak_timestamp: ISO8601}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_required([:channel_id])

    {:patch, "/guilds/#{guild_id}/voice-states/@me", nil, nil, body}
    |> request()
  end

  # TODO: Add Helpers. eg kick user from voice channel, move user, etc.
  @doc """
  Modify a users voice state.

  ## Options

  - `:channel_id`  - `:snowflake` - The id of the channel the user is currently in.
  - `:suppress`  - `:boolean` - Toggles the user's suppress state

  > `:channel_id` must currently point to a stage channel.
  > User must already have joined `:channel_id`.
  > You must have the `:MUTE_MEMBERS` permission. (Since suppression is the only thing that is available currently.)
  > When unsuppressed, non-bot users will have their `:request_to_speak_timestamp` set to the current time. Bot users will not.
  > When suppressed, the user will have their `:request_to_speak_timestamp` removed.

  ## Examples

      iex> Remedy.API.modify_user_voice_state(



  """
  @doc since: "0.6.8"
  @doc permissions: [:MUTE_MEMBERS]
  @doc events: [:VOICE_STATE_UPDATE]
  @doc method: "PATCH"
  @doc route: "/guilds/:guild_id/voice-states/:user_id"
  @unsafe {:modify_user_voice, [:guild_id, :user_id, :opts]}
  @spec modify_user_voice(snowflake, snowflake, opts) :: {:ok, any} | {:error, reason}
  def modify_user_voice(guild_id, user_id, opts \\ []) do
    data = %{}
    types = %{channel_id: Snowflake, suppress: :boolean}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_required([:channel_id])

    {:patch, "/guilds/#{guild_id}/voice-states/#{user_id}", nil, nil, body}
    |> request()
  end

  ## Guild Template
  @doc """
  Get a guild template from the code or the full URL.

  eg: https://discord.new/2KAaMpa22ea6

  ## Examples

      iex> Remedy.API.get_guild_template(https://discord.new/2KAaMpa22ea6)
      {:ok, %Remedy.Schema.GuildTemplate{}}

  """
  @doc since: "0.6.8"
  @doc method: "GET"
  @doc route: "guild-templates/:template_id"
  @unsafe {:get_guild_template, [:template_id]}
  @spec get_guild_template(any) :: {:error, reason} | {:ok, any}
  def get_guild_template("https://discord.new/" <> template_code),
    do: get_guild_template(template_code)

  def get_guild_template(template_code) do
    {:get, "/guilds/templates/#{template_code}", nil, nil, nil}
    |> request()
  end

  @doc false
  @doc since: "0.6.8"
  @doc events: [:GUILD_CREATE]
  @doc method: "POST"
  @doc route: "guild-templates/:template_id"
  @unsafe {:create_guild_from_template, [:template_id, :opts]}
  @spec create_guild_from_template(snowflake, opts) :: {:ok, any} | {:error, reason}
  defp create_guild_from_template(template_code, opts) when not is_list(template_code) do
    data = %{}
    types = %{name: :string, icon: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_required([:name])

    {:post, "/guilds/templates/#{template_code}", nil, nil, body}
    |> request()
  end

  @doc """
  Creates a template from the guild.

  ## Options

  - `:name`  - `:string, min: 2, max: 100` - The name of the template.
  - `:description`  - `:string, min: 0, max: 120` - The description of the template.

  ## Examples

      iex> Remedy.API.create_template(%{name: "Test Guild Template", description: "This is a test guild template."})
      {:ok, %Remedy.Schema.GuildTemplate{}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc events: [:GUILD_TEMPLATE_CREATE]
  @doc method: "POST"
  @doc route: "/guilds/:guild_id/templates"
  @unsafe {:create_template, [:guild_id, :opts]}
  @spec create_template(snowflake, opts) :: {:ok, any} | {:error, reason}
  def create_template(guild_id, opts \\ []) do
    data = %{}
    types = %{name: :string, description: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_required([:name])
      |> validate_length(:name, min: 2, max: 100)
      |> validate_length(:description, min: 0, max: 120)

    {:post, "/guilds/#{guild_id}/templates", nil, nil, body}
    |> request()
    |> shape()
  end

  @doc """
  Sync a guild template to the guilds current state

  ## Examples

      iex> Remedy.API.sync_template("2KAaMpa22ea6")
      {:ok, %Remedy.Schema.GuildTemplate{}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "PUT"
  @doc route: "/guilds/:guild_id/templates/:template_id"
  @unsafe {:sync_template, [:guild_id, :template_id]}
  @spec sync_template(snowflake, snowflake) :: {:ok, any} | {:error, reason}
  def sync_template(guild_id, template_code) do
    {:put, "/guilds/#{guild_id}/templates/#{template_code}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Modifies a templates metadata.

  ## Options

  - `:name`  - `:string, min: 1, max: 100` - The name of the template.
  - `:description`  - `:string, min: 0, max: 120` - The description of the template.

  ## Examples

      iex> Remedy.API.modify_template(872417560094732328, "2KAaMpa22ea6", name: "Test Guild Template", description: "This is a test guild template.")
      {:ok, %Remedy.Schema.GuildTemplate{}}


  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "PATCH"
  @doc route: "/guilds/:guild_id/templates/:template_id"
  @unsafe {:modify_template, [:guild_id, :template_id, :opts]}
  @spec modify_template(snowflake, snowflake, opts) :: {:ok, any} | {:error, reason}
  def modify_template(guild_id, template_code, opts \\ []) do
    data = %{}
    types = %{name: :string, description: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_length(:name, min: 1, max: 100)
      |> validate_length(:description, min: 0, max: 120)

    {:patch, "/guilds/#{guild_id}/templates/#{template_code}", nil, nil, body}
    |> request()
    |> shape()
  end

  @doc """
  Delete a template.

  ## Examples

      iex> Remedy.API.delete_template(872417560094732328, "2KAaMpa22ea6")
      {:ok, %Remedy.Schema.GuildTemplate{}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_GUILD]
  @doc method: "DELETE"
  @doc route: "/guilds/:guild_id/templates/:template_id"
  @unsafe {:delete_template, [:guild_id, :template_id]}
  @spec delete_template(snowflake, snowflake) :: {:ok, any} | {:error, reason}
  def delete_template(guild_id, template_code) do
    {:delete, "/guilds/#{guild_id}/templates/#{template_code}", nil, nil, nil}
    |> request()
    |> shape()
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

    - `:with_counts`  - `:boolean` - Whether to include the approximate member counts.
    - `:with_expiration`  - `:boolean` - Whether to include the expiration date.
    - `:guild_scheduled_event_id`  - `Snowflake` - The ID of the guild scheduled event to include with the invite.

  ## Examples

      iex> Remedy.API.get_invite("zsjUsC")
      {:ok, %Remedy.Schema.Invite{}}

      iex> Remedy.API.get_invite("zsjUsC", with_counts: true)
      {:ok, %Remedy.Schema.Invite{}}

  """
  @doc since: "0.6.8"
  @doc method: "GET"
  @doc route: "/invites/:invite_code"
  @unsafe {:get_invite, [:invite_code, :opts]}
  @spec get_invite(any, opts) :: {:ok, any} | {:error, reason}
  def get_invite(invite_code, opts \\ []) do
    data = %{}
    types = %{with_counts: :boolean, with_expiration: :boolean, guild_scheduled_event_id: Snowflake}
    params = Enum.into(opts, %{})
    keys = Map.keys(types)

    params =
      {data, types}
      |> cast(params, keys)

    {:get, "/invites/#{invite_code}", params, nil, nil}
    |> request()
  end

  @doc """
  Deletes an invite by its invite code.

  ## Examples

      iex> Remedy.API.delete_invite("zsjUsC")
      {:ok, %Remedy.Schema.Invite{}}

  """
  @doc since: "0.6.8"
  @doc permissions: [:MANAGE_CHANNELS]
  @doc events: [:INVITE_DELETE]
  @doc method: "DELETE"
  @doc route: "/invites/:invite_code"
  @unsafe {:delete_invite, [:invite_code]}
  @spec delete_invite(any, opts) :: {:ok, any} | {:error, reason}
  def delete_invite(invite_code, opts \\ []) do
    reason = opts[:reason]

    {:delete, "/invites/#{invite_code}", nil, reason, nil}
    |> request()
    |> shape(Invite)
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

  @doc """
  Create a new stage instance associated to a stage channel.

  Requires the user to be a moderator of the Stage channel.

  ## Options

  - `:channel_id`  - `Snowflake`
  - `:name`  - `:string`
  - `:privacy_level`  - `:integer`
    - 1 - PUBLIC, The Stage instance is visible publicly, such as on Stage Discovery.
    - 2 - GUILD_ONLY,	The Stage instance is visible to only guild members.

  ## Examples

      iex> Remedy.API.create_stage(channel_id: "123456789012345678901234", name: "My Stage", privacy_level: 0)
      {:ok, %Remedy.Schema.Stage{}}

  """
  @doc since: "0.6.8"
  @doc events: [:STAGE_CREATE]
  @doc method: "POST"
  @doc route: "/stage-instances"
  @doc audit_log: true
  @unsafe {:create_stage, [:opts]}
  @spec create_stage(opts) :: {:ok, any} | {:error, reason}
  def create_stage(opts) do
    data = %{}
    types = %{channel_id: Snowflake, name: :string, privacy_level: :integer}
    params = Enum.into(opts, %{})
    keys = Map.keys(types)
    reason = opts[:reason]

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_inclusion(:privacy_level, [1, 2])

    {:post, "/stage-instances", nil, reason, body}
    |> request()
    |> shape(Stage)
  end

  @doc """
  Get a stage instance.

  ## Examples

      iex> Remedy.API.get_stage(123456789012345678901234")
      {:ok, %Remedy.Schema.Stage{}}

  """
  @doc since: "0.6.8"
  @doc method: "GET"
  @doc route: "/stage-instances/:channel_id"
  @unsafe {:get_stage, [:channel_id]}
  @spec get_stage(snowflake) :: {:ok, any} | {:error, reason}
  def get_stage(channel_id) do
    {:get, "/stage-instances/#{channel_id}", nil, nil, nil}
    |> request()
    |> shape(Stage)
  end

  @doc """
  Modify a stage instance.

  ## Options

  - `:name`  - `:string`
  - `:privacy_level`  - `:integer`
    - 1 - PUBLIC, The Stage instance is visible publicly, such as on Stage Discovery.
    - 2 - GUILD_ONLY,	The Stage instance is visible to only guild members.

  ## Examples

      iex> Remedy.API.modify_stage(123456789012345678901234, name: "My Stage", privacy_level: 0)
      {:ok, %Remedy.Schema.Stage{}}

  """
  @doc since: "0.6.8"
  @doc events: [:STAGE_UPDATE]
  @doc method: "PATCH"
  @doc route: "/stage-instances/:channel_id"
  @doc audit_log: true
  @unsafe {:modify_stage, [:channel_id, :opts]}
  @spec modify_stage(snowflake, opts) :: {:ok, any} | {:error, reason}
  def modify_stage(channel_id, opts \\ []) do
    data = %{}
    types = %{topic: :string, privacy_level: :integer}
    keys = Map.keys(types)
    reason = opts[:reason]
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_inclusion(:privacy_level, [1, 2])

    {:patch, "/stage-instances/#{channel_id}", nil, reason, body}
    |> request()
    |> shape(Stage)
  end

  @doc """
  Deletes a stage instance.

  ## Examples

      iex> Remedy.API.delete_stage(123456789012345678901234)
      {:ok, %Remedy.Schema.Stage{}}

  """
  @doc since: "0.6.8"
  @doc events: [:STAGE_DELETE]
  @doc method: "DELETE"
  @doc route: "/stage-instances/:channel_id"
  @doc audit_log: true
  @unsafe {:delete_stage, [:channel_id]}
  @spec delete_stage(snowflake, opts) :: {:ok, any} | {:error, reason}
  def delete_stage(channel_id, opts) do
    reason = opts[:reason]

    {:delete, "/stage-instances/#{channel_id}", nil, reason, nil}
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
  @doc section: :stickers
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/stickers/:sticker_id"
  @unsafe {:get_sticker, [:sticker_id]}
  @spec get_sticker(snowflake) :: {:error, any} | {:ok, Sticker.t()}
  def get_sticker(sticker_id) do
    {:get, "/stickers/#{sticker_id}", nil, nil, nil}
    |> request()
    |> shape(Sticker)
  end

  #############################################################################
  ##  @doc """
  ##  List the Nitro Sticker Packs
  ##  """
  @doc false
  @doc since: "0.6.0"
  @unsafe {:list_nitro_sticker_packs, []}
  @spec list_nitro_sticker_packs() :: {:error, reason} | {:ok, [Sticker.t()]}
  def list_nitro_sticker_packs do
    {:get, "/sticker-packs", nil, nil, nil} |> request() |> shape(StickerPack)
  end

  @doc """
  List all custom stickers for a guild.

  ## Examples

      iex> Remedy.API.list_stickers(guild_id)
      {:ok, [%Sticker{}]}

      iex> Remedy.API.get_sticker(123)
      {:error, {404, 10060, "Unknown guild"}}

  """
  @doc section: :stickers
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/guilds/:guild_id/stickers"
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
  @doc section: :stickers
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/guilds/:guild_id/stickers/:sticker_id"
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
  @doc section: :stickers
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_EMOJIS_AND_STICKERS"]
  @doc events: "GUILD_STICKERS_UPDATE"
  @doc method: "POST"
  @doc route: "/guilds/:guild_id/stickers"
  @doc audit_log: true
  @unsafe {:create_sticker, [:guild_id, :sticker_id, :opts]}
  @spec create_sticker(snowflake, snowflake, opts) :: {:error, reason} | {:ok, Sticker.t()}
  def create_sticker(guild_id, sticker_id, opts \\ []) do
    data = %{}
    types = %{name: :string, description: :string, tags: :string, file: :string}
    keys = Map.keys(types)
    reason = opts[:reason]
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:post, "/guilds/#{guild_id}/stickers/#{sticker_id}", nil, reason, body}
    |> request()
    |> shape(Sticker)
  end

  @doc """
  Modify a sticker.

  ## Options

  - `:name, :string, min: 2, max: 30` - name of the sticker (2-30 characters)
  - `:description, :string, min: 2, max: 30` - description of the sticker (empty or 2-100 characters)
  - `:tags, :string, max: 200` - autocomplete/suggestion tags for the sticker (max 200 characters)\

  ## Examples

      iex> Remedy.API.modify_sticker(guild_id, sticker_id, sticker_map)
      {:ok, Sticker.t()}

      iex> Remedy.API.modify_sticker(guild_id, sticker_id, bad_sticker_map)
      {:error, {404, 10060, "Invalid Form Body"}}

  """
  @doc section: :stickers
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_EMOJIS_AND_STICKERS"]
  @doc events: "GUILD_STICKERS_UPDATE"
  @doc method: "PATCH"
  @doc route: "/guilds/:guild_id/stickers/:sticker_id"
  @doc audit_log: true
  @unsafe {:modify_sticker, [:guild_id, :sticker_id, :opts]}
  @spec modify_sticker(snowflake, snowflake, opts) :: {:error, reason} | {:ok, Sticker.t()}
  def modify_sticker(guild_id, sticker_id, opts \\ []) do
    data = %{}
    types = %{name: :string, description: :string, tags: :string}
    keys = Map.keys(types)
    reason = opts[:reason]
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:post, "/guilds/#{guild_id}/stickers/#{sticker_id}", nil, reason, body}
    |> request()
  end

  @doc """
  Deletes a sticker.

  ## Examples

      iex> Remedy.API.delete_sticker(guild_id, sticker_id)
      {:ok, %Sticker{}}

      iex Remedy.API.delete_sticker(bad_guild_id, sticker_id)
      {:error, {404, 10060, "Unknown guild"}}

      iex> Remedy.API.delete_sticker(guild_id, bad_sticker_id)
      {:error, {404, 10060, "Unknown Sticker"}}

  """
  @doc section: :stickers
  @doc since: "0.6.0"
  @doc permissions: ["MANAGE_EMOJIS_AND_STICKERS"]
  @doc events: "GUILD_STICKERS_UPDATE"
  @doc method: "DELETE"
  @doc route: "/guilds/:guild_id/stickers/:sticker_id"
  @doc audit_log: true
  @unsafe {:delete_sticker, [:guild_id, :sticker_id]}
  @spec delete_sticker(snowflake, snowflake, opts) :: {:error, reason} | :ok
  def delete_sticker(guild_id, sticker_id, opts \\ []) do
    {:delete, "/guilds/#{guild_id}/stickers/#{sticker_id}", nil, opts[:reason], nil}
    |> request()
    |> shape()
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
      {:ok, %Remedy.Schema.User{}}

  """
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/users/@me"
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
  @doc method: "GET"
  @doc route: "/users/:user_id"
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
  @doc method: "PATCH"
  @doc route: "/users/@me"
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
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/users/@me/guilds"
  @unsafe {:list_guilds, [:opts]}
  @spec list_guilds(opts) :: {:error, reason} | {:ok, [Guild.t()]}
  def list_guilds(opts) do
    data = %{limit: 50}
    types = %{before: Snowflake, after: Snowflake, limit: :integer}
    keys = Map.keys(types)
    reason = opts[:reason]
    params = Enum.into(opts, %{})

    params =
      {data, types}
      |> cast(params, keys)

    {:get, "/users/@me/guilds", params, reason, nil}
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
  @doc since: "0.6.0"
  @doc method: "DELETE"
  @doc route: "/users/@me/guilds/:guild_id"
  @unsafe {:leave_guild, [:guild_id]}
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
  @doc since: "0.6.0"
  @doc method: "POST"
  @doc route: "/users/@me/channels"
  @unsafe {:create_dm, [:user_id]}
  @spec create_dm(snowflake) :: {:error, reason} | {:ok, Channel.t()}
  def create_dm(user_id) do
    body = %{recipient_id: user_id}

    {:post, "/users/@me/channels", nil, nil, body}
    |> request()
    |> shape(Channel)
  end

  ###########################################################################
  ## Create a group dm
  ##
  ## Only for GameSDK. Not for us
  ## @doc since: "0.6.8"
  @doc false
  @unsafe {:create_group_dm, [:opts]}
  @spec create_group_dm(any) :: {:error, reason} | {:ok, Channel.t()}
  def create_group_dm(opts), do: {:post, "/users/@me/channels", nil, nil, opts} |> request()

  ###########################################################################
  ## Get a list of the bot's user connections
  ##
  ## Useless, bots have no friends :(
  ## @doc since("0.6.8")
  @doc false
  @unsafe {:list_bot_connections, []}
  @spec list_bot_connections() :: {:error, any} | {:ok, any}
  def list_bot_connections do
    {:get, "/users/@me/connections", nil, nil, nil}
    |> request()
  end

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
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/voice/regions"
  @unsafe {:list_voice_regions, []}
  @spec list_voice_regions() :: {:error, reason} | {:ok, [VoiceRegion.t()]}
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

  @doc """
  Creates a webhook.

  ## Options

  - `:name`  - `:string, min: 1, max: 80` - The name of the webhook, cannot be 'Clyde'.
  - `:avatar`  - `:string, max: 2048` - The avatar of the webhook, as a base64-encoded string.

  ## Examples

      iex> Remedy.API.create_webhook(a_channel_id, {name: "My Webhook", avatar: "..."})
      {:ok, %Remedy.Schema.Webhook{}}

  """
  @doc section: :webhooks
  @doc since: "0.6.0"
  @doc permissions: "MANAGE_WEBHOOKS"
  @doc method: "POST"
  @doc route: "/channels/:channel_id/webhooks"
  @unsafe {:create_webhook, [:channel_id, :opts]}
  @spec create_webhook(snowflake, opts) :: {:error, reason} | {:ok, Webhook.t()}
  def create_webhook(channel_id, opts \\ []) do
    data = %{}
    types = %{name: :string, avatar: :string}
    params = Enum.into(opts, %{})
    keys = Map.keys(types)

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_exclusion(:name, ["Clyde"])
      |> validate_length(:name, min: 1, max: 80)

    {:post, "/channels/#{channel_id}/webhooks", nil, nil, body}
    |> request()
  end

  @doc """
  Gets a list of webook for a channel.

  ## Examples

        iex> Remedy.API.list_webhooks(a_channel_id)
        {:ok, [%Remedy.Schema.Webhook{}]}

  """
  @doc since: "0.6.0"
  @doc permissions: "MANAGE_WEBHOOKS"
  @doc method: "GET"
  @doc route: "/channels/:channel_id/webhooks"
  @unsafe {:list_channel_webhooks, [:channel_id]}
  @spec list_channel_webhooks(snowflake) :: {:error, reason} | {:ok, [Webhook.t()]}
  def list_channel_webhooks(channel_id) do
    {:get, "/channels/#{channel_id}/webhooks", nil, nil, nil}
    |> request()
  end

  @doc """
  Gets a list of webooks for a guild.

  ## Examples

        iex> Remedy.API.list_guild_webhooks(a_guild_id)
        {:ok, [%Remedy.Schema.Webhook{}]}

  """
  @doc since: "0.6.0"
  @doc permissions: "MANAGE_WEBHOOKS"
  @doc method: "GET"
  @doc route: "/guilds/:guild_id/webhooks"
  @unsafe {:list_guild_webhooks, [:guild_id]}
  @spec list_guild_webhooks(snowflake) :: {:error, reason} | {:ok, [Webhook.t()]}
  def list_guild_webhooks(guild_id) do
    {:get, "/guilds/#{guild_id}/webhooks", nil, nil, nil}
    |> request()
  end

  @doc """
  Gets a webhook by id.

  ## Examples

        iex> Remedy.API.get_webhook(a_webhook_id)
        {:ok, %Remedy.Schema.Webhook{}}

  """
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/webhooks/:webhook_id"
  @unsafe {:get_webhook, [:webhook_id]}
  @spec get_webhook(snowflake) :: {:error, reason} | {:ok, Webhook.t()}
  def get_webhook(webhook_id) do
    {:get, "/webhooks/#{webhook_id}", nil, nil, nil}
    |> request()
  end

  @doc """
  Gets a webhook by id and token.

  ## Examples

        iex> Remedy.API.get_webhook_with_token(a_webhook_id, a_token)
        {:ok, %Remedy.Schema.Webhook{}}

  """
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/webhooks/:webhook_id/:webhook_token"
  @unsafe {:get_webhook_with_token, [:webhook_id, :webhook_token]}
  def get_webhook(webhook_id, webhook_token) do
    {:get, "/webhooks/#{webhook_id}/#{webhook_token}", nil, nil, nil}
    |> request()
  end

  @doc """
  Modifies a webhook.

  ## Options

  - `:name`  - `:string, min: 1, max: 80` - The name of the webhook, cannot be 'Clyde'.
  - `:avatar`  - `:string, max: 2048` - The avatar of the webhook, as a base64-encoded string.
  - `:channel_id`  - `:snowflake` - The channel id to move the webhook to.

  ## Examples

      iex> Remedy.API.modify_webhook(a_webhook_id, {name: "My Webhook", avatar: "..."})
      {:ok, %Remedy.Schema.Webhook{}}

  """
  @doc since: "0.6.0"
  @doc permissions: "MANAGE_WEBHOOKS"
  @doc method: "PATCH"
  @doc route: "/webhooks/:webhook_id"
  @unsafe {:modify_webhook, [:webhook_id, :opts]}
  @spec modify_webhook(snowflake, opts) :: {:error, reason} | {:ok, Webhook.t()}
  def modify_webhook(webhook_id, opts) do
    data = %{}
    types = %{name: :string, avatar: :string, channel_id: Snowflake}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/webhooks/#{webhook_id}", nil, nil, body}
    |> request()
  end

  @doc """
  Modifies a webhook with a token.

  This method is exactly like `modify_webhook/1` but does not require
  authentication.

  ## Options

  - `:name`  - `:string, min: 1, max: 80` - The name of the webhook, cannot be 'Clyde'.
  - `:avatar`  - `:string, max: 2048` - The avatar of the webhook, as a base64-encoded string.

  ## Examples

      iex> Remedy.API.modify_webhook_with_token(a_webhook_id, a_token, {name: "My Webhook", avatar: "..."})
      {:ok, %Remedy.Schema.Webhook{}}

  """
  @doc since: "0.6.0"
  @doc method: "PATCH"
  @doc route: "/webhooks/:webhook_id/:webhook_token"
  @unsafe {:modify_webhook_with_token, [:webhook_id, :webhook_token, :opts]}
  def modify_webhook(webhook_id, webhook_token, opts) do
    data = %{}
    types = %{name: :string, avatar: :string}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/webhooks/#{webhook_id}/#{webhook_token}", nil, nil, body}
    |> request()
  end

  @doc """
  Deletes a webhook by id.

  ## Examples

      iex> Remedy.API.delete_webhook(a_webhook_id)
      :ok

  """
  @doc since: "0.6.0"
  @doc permissions: "MANAGE_WEBHOOKS"
  @doc method: "DELETE"
  @doc route: "/webhooks/:webhook_id"
  @unsafe {:delete_webhook, [:webhook_id]}
  @spec delete_webhook(snowflake) :: {:error, reason} | :ok
  def delete_webhook(webhook_id) do
    {:delete, "/webhooks/#{webhook_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Deletes a webhook by id and token.

  ## Examples

      iex> Remedy.API.delete_webhook_with_token(a_webhook_id, a_token)
      :ok

  """
  @doc since: "0.6.0"
  @doc method: "DELETE"
  @doc route: "/webhooks/:webhook_id/:webhook_token"
  @unsafe {:delete_webhook_with_token, [:webhook_id, :webhook_token]}
  @spec delete_webhook(snowflake, any) :: {:error, any} | {:ok, any}
  def delete_webhook(webhook_id, webhook_token) do
    {:delete, "/webhooks/#{webhook_id}/#{webhook_token}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Execute a webhook.

  ## Options

  - `:wait`  - (`:boolean`) Wait for server confirmation of message send before response, and returns the created message body (defaults to false; when false a message that is not saved does not return an error)
  - `:thread_id`  - `Snowflake` - Send a message to the specified thread within a webhook's channel. The thread will automatically be unarchived.
  - `:content`  - `:string, max: 2000` - The content of the webhook message.
  - `:username`  - `:string` - Override the username of the webhook message.
  - `:avatar_url`  - `:string` - Override the avatar of the webhook message.
  - `:tts`  - `:boolean` - Whether the message should be read aloud by Discord.
  - `:embeds`  - `{:array, Embed}` - An array of up to 10 embed objects.
  - `:allowed_mentions`  - `AllowedMention` - allowed mention object.
  - `:components`  - `{:array, Component}` - An array of component objects.
  - `:attachments`  - `{:array, Attachment}` - An array of attachment objects.

  > Components requires an application-owned webhook.

  ## Examples

      iex> Remedy.API.execute_webhook(a_webhook_id, {content: "Hello, world!"})
      {:ok, %Remedy.Schema.Message{}}

  """
  @doc since: "0.6.0"
  @doc method: "POST"
  @doc route: "/webhooks/:webhook_id/:webhook_token"
  @unsafe {:execute_webhook, [:webhook_id, :webhook_token, :opts]}
  @spec execute_webhook(snowflake, any, opts) :: {:error, reason} | {:ok, Message.t()}
  def execute_webhook(webhook_id, webhook_token, opts) do
    query_data = %{wait: false}
    query_types = %{wait: :boolean, thread_id: Snowflake}
    query_keys = Map.keys(query_types)
    params = Enum.into(opts, %{})

    query_params =
      {query_data, query_types}
      |> cast(params, query_keys)

    types = %{
      content: :string,
      username: :string,
      avatar_url: :string,
      tts: :boolean,
      embeds: {:array, Embed},
      allowed_mentions: AllowedMention,
      components: {:array, Component},
      attachments: {:array, Attachment}
    }

    data = %{}
    keys = Map.keys(types)

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_at_least_one([:content, :embeds, :attachments])

    reason = opts[:reason]

    {:post, "/webhooks/#{webhook_id}/#{webhook_token}", query_params, reason, body}
    |> request()
  end

  ############################################################################
  ## We are not slack
  @doc false
  @doc since: "0.6.8"
  @doc method: "GET"
  @doc route: "/webhooks/:webhook_id/:webhook_token/slack"
  @unsafe {:execute_slack_webhook, [:webhook_id, :webhook_token]}
  @spec execute_slack_webhook(snowflake, any) :: {:error, reason} | :ok
  def execute_slack_webhook(webhook_id, webhook_token) do
    {:post, "/webhooks/#{webhook_id}/#{webhook_token}/slack", nil, nil, nil}
    |> request()
  end

  ############################################################################
  ## We are not github
  @doc false
  @doc since: "0.6.8"
  @doc method: "GET"
  @doc route: "/webhooks/:webhook_id/:webhook_token/github"
  @unsafe {:execute_github_webhook, [:webhook_id, :webhook_token]}
  @spec execute_github_webhook(snowflake, token) :: {:error, reason} | :ok
  def execute_github_webhook(webhook_id, webhook_token) do
    {:post, "/webhooks/#{webhook_id}/#{webhook_token}/github", nil, nil, nil}
    |> request()
  end

  @doc """
  Get a webhook message.

  ## Options

  - `:thread_id`  - `Snowflake` - Get a message from the specified thread within a webhook's channel.

  ## Examples

      iex> Remedy.API.get_message(a_webhook_id, a_webhook_token, a_message_id)
      {:ok, %Remedy.Schema.Message{}}

  """
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/webhooks/:webhook_id/:webhook_token/messages/:message_id"
  @unsafe {:get_message, [:webhook_id, :webhook_token, :message_id, :opts]}
  @spec get_message(snowflake, any, snowflake, opts) :: {:error, reason} | {:ok, Message.t()}
  def get_message(webhook_id, webhook_token, message_id, opts \\ []) do
    data = %{}
    types = %{thread_id: Snowflake}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    query =
      {data, types}
      |> cast(params, keys)

    {:get, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}", query, nil, nil}
    |> request()
    |> shape(Message)
  end

  @doc """
  Modify a webhook message.

  ## Options

  - `:content`  - `:string, max: 2000` - The content of the webhook message.
  - `:username`  - `:string` - Override the username of the webhook message.
  - `:avatar_url`  - `:string` - Override the avatar of the webhook message.
  - `:tts`  - `:boolean` - Whether the message should be read aloud by Discord.
  - `:embeds`  - `{:array, Embed}` - An array of up to 10 embed objects.
  - `:allowed_mentions`  - `AllowedMention` - allowed mention object.
  - `:components`  - `{:array, Component}` - An array of component objects.
  - `:attachments`  - `{:array, Attachment}` - An array of attachment objects.

  > Components requires an application-owned webhook.

  ## Examples

      iex> Remedy.API.modify_message(a_webhook_id, a_webhook_token, a_message_id, {content: "Hello, world!"})
      {:ok, %Remedy.Schema.Message{}}


  """
  @doc since: "0.6.0"
  @doc method: "PATCH"
  @doc route: "/webhooks/:webhook_id/:webhook_token/messages/:message_id"
  @unsafe {:modify_message, [:webhook_id, :webhook_token, :message_id, :opts]}
  @spec modify_message(snowflake, any, snowflake, opts) :: {:error, reason} | {:ok, Message.t()}
  def modify_message(webhook_id, webhook_token, message_id, opts) do
    query_data = %{wait: false}
    query_types = %{wait: :boolean, thread_id: Snowflake}
    query_keys = Map.keys(query_types)
    params = Enum.into(opts, %{})

    query_params =
      {query_data, query_types}
      |> cast(params, query_keys)

    types = %{
      content: :string,
      username: :string,
      avatar_url: :string,
      tts: :boolean,
      embeds: {:array, Embed},
      allowed_mentions: AllowedMention,
      components: {:array, Component},
      attachments: {:array, Attachment}
    }

    data = %{}
    keys = Map.keys(types)

    body =
      {data, types}
      |> cast(params, keys)
      |> validate_at_least_one([:content, :embeds, :attachments])

    reason = opts[:reason]

    {:patch, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}", query_params, reason, body}
    |> request()
  end

  @doc """
  Delete a webhook message.

  ## Examples

      iex> Remedy.API.delete_message(a_webhook_id, a_webhook_token, a_message_id)
      {:ok, %Remedy.Schema.Message{}}

  """
  @doc since: "0.6.0"
  @doc method: "DELETE"
  @doc route: "/webhooks/:webhook_id/:webhook_token/messages/:message_id"
  @unsafe {:delete_message, [:webhook_id, :webhook_token, :message_id, :opts]}
  @spec delete_message(snowflake, any, snowflake, opts) :: {:error, reason} | {:ok, Message.t()}
  def delete_message(webhook_id, webhook_token, message_id, opts) do
    data = %{}
    types = %{thread_id: Snowflake}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    query =
      {data, types}
      |> cast(params, keys)

    {:delete, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}", query, nil, nil}
    |> request()
    |> shape()
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
  List all global commands.

  ## Example

      iex> Remedy.API.list_commands
      {:ok, [%{application_id: "455589479713865749"}]}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/applications/:application_id/commands"
  @unsafe {:list_commands, []}
  @spec list_commands() :: {:error, reason} | {:ok, [Command.t()]}
  def list_commands do
    {:get, "/applications/#{bot_id()}/commands", nil, nil, nil}
    |> request()
  end

  @doc """
  Create a new global application command.

  > New global commands will be available in all guilds after 1 hour.

  > If an existing command with the same name exists, it will be overwritten.

  ## Options

  - `:name`  - `:string, min: 1, max: 32`
  - `:description` - `:string, min: 1, max: 100`
  - `:options`  - `{:array, CommandOption}`
  - `:default_permission`  - `:boolean, default: true`
  - `:type`  - `:integer`
    `1` - `:chat_input` - Slash commands; a text-based command that shows up when a user types `/`
    `2` - `:user` - A UI-based command that shows up when you right click or tap on a user
    `3` - `:message` - A UI-based command that shows up when you right click or tap on a message

  ## Example

      iex>  Remedy.API.create_command(%{name: "edit", description: "ed, man! man, ed", options: []})
      {:ok, %Remedy.Schema.Command{}}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "POST"
  @doc route: "/applications/:application_id/commands"
  @unsafe {:create_command, [:opts]}
  @spec create_command(opts) :: {:error, reason} | {:ok, Command.t()}
  def create_command(opts) do
    data = %{default_permission: true}

    types = %{
      name: :string,
      description: :string,
      options: {:array, CommandOption},
      default_permission: :boolean,
      type: :integer
    }

    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:post, "/applications/#{bot_id()}/commands", nil, nil, body}
    |> request()
    |> shape(Command)
  end

  @doc """

  Gets a global application command.

  ## Examples

      iex> Remedy.API.get_global_command(good_command_id)
      {:ok, %Command{}}

      iex> Remedy.API.get_global_command(bad_command_id)
      {:error, reason}


  """
  @doc section: :commands
  @doc since: "0.6.8"
  @doc method: "GET"
  @doc route: "/applications/:application_id/commands/:command_id"
  @unsafe {:get_command, [:command_id]}
  @spec get_command(snowflake) :: {:error, reason} | {:ok, Command.t()}
  def get_command(command_id) do
    {:get, "/applications/#{bot_id()}/commands/#{command_id}", nil, nil, nil}
    |> request()
    |> shape(Command)
  end

  @doc """
  Update an existing global application command.

  > Note: It can take up to one hour to update global commands.

  ## Options

  - `:name`  - `:string, min: 1, max: 32`
  - `:description` - `:string, min: 1, max: 100`
  - `:options`  - `{:array, CommandOption}`
  - `:default_permission`  - `:boolean, default: true` - whether the command is enabled by default when the app is added to a guild

  ## Examples

      iex> Remedy.API.update_command(good_command_id, %{name: "edit", descrip

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "PATCH"
  @doc route: "/applications/:application_id/commands/:command_id"
  @unsafe {:modify_command, [:command_id, :opts]}
  @spec modify_command(snowflake, opts) :: {:error, reason} | {:ok, Command.t()}
  def modify_command(command_id, opts) do
    data = %{}
    types = %{name: :string, description: :string, options: {:array, CommandOption}, default_permission: :boolean}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/applications/#{bot_id()}/commands/#{command_id}", nil, nil, body}
    |> request()
  end

  @doc """
  Delete an existing global application command.

  > Note: It can take up to one hour to update global commands.

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "DELETE"
  @doc route: "/applications/:application_id/commands/:command_id"
  @unsafe {:delete_command, [:command_id]}
  @spec delete_command(snowflake) :: {:error, reason} | :ok
  def delete_command(command_id) do
    {:delete, "/applications/#{bot_id()}/commands/#{command_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Overwrite the existing global application commands.

  Updates will be available in all guilds after 1 hour.

  This action will:
  - Create any command that was provided and did not already exist
  - Update any command that was provided and already existed if its configuration changed
  - Delete any command that was not provided but existed on Discord's end

  ## Options

  - `:commands`  - `{:array, Command}`

  ## Examples

      iex> Remedy.API.overwrite_commands(commands: [%{name: "edit", description: "new description"}])
      {:ok, [%Remedy.Schema.Command{}]}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "PUT"
  @doc route: "/applications/:application_id/commands"
  @unsafe {:cast_commands, [:commands]}
  @spec cast_commands(opts) :: {:error, reason} | {:ok, [Command.t()]}
  def cast_commands(opts)

  def cast_commands(opts) do
    body = %{}

    types = %{
      commands: {:array, Command}
    }

    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {body, types}
      |> cast(params, keys)

    {:put, "/applications/#{bot_id()}/commands", nil, nil, body}
    |> request()
    |> shape(Command)
  end

  @doc """
  List guild commands.

  ## Examples

        iex> Remedy.API.list_commands(guild_id)
        {:ok, [%{application_id: "455589479713865749"}]}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/applications/:application_id/guilds/:guild_id/commands"
  @unsafe {:list_commands, [:guild_id]}
  @spec list_commands(snowflake) :: {:error, reason} | {:ok, [Command.t()]}
  def list_commands(guild_id) do
    {:get, "/applications/#{bot_id()}/guilds/#{guild_id}/commands", nil, nil, nil}
    |> request()
    |> shape(Command)
  end

  @doc """
  Create a guild application command.

  ## Options

  - `:name`  - `:string, min: 1, max: 32`
  - `:description` - `:string, min: 1, max: 100`
  - `:options`  - `{:array, CommandOption}`
  - `:default_permission`  - `:boolean, default: true` - whether the command is enabled by default when the app is added to a guild
  - `:type`  - `:integer`
    `1` - `:chat_input` - Slash commands; a text-based command that shows up when a user types `/`
    `2` - `:user` - A UI-based command that shows up when you right click or tap on a user
    `3` - `:message` - A UI-based command that shows up when you right click or tap on a message

    ## Examples

        iex> Remedy.API.create_command(guild_id, name: "command", description: "my new command")
        {:ok, %Command{}}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "POST"
  @doc route: "/applications/:application_id/guilds/:guild_id/commands"
  @unsafe {:create_command, [:guild_id, :opts]}
  @spec create_command(snowflake, opts) :: {:error, reason} | {:ok, Command.t()}
  def create_command(guild_id, opts) do
    body = %{}

    types = %{
      name: :string,
      description: :string,
      options: {:array, CommandOption},
      default_permission: :boolean,
      type: :integer
    }

    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {body, types}
      |> cast(params, keys)

    {:post, "/applications/#{bot_id()}/guilds/#{guild_id}/commands", nil, nil, body}
    |> request()
    |> shape(Command)
  end

  @doc """
  Get a guild command.

  ## Examples

      iex> Remedy.API.get_command(guild_id, good_command_id)
      {:ok, %Command{}}

      iex> Remedy.API.get_command(guild_id, bad_command_id)
      {:error, reason}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/applications/:application_id/guilds/:guild_id/commands/:command_id"
  @unsafe {:get_command, [:guild_id, :command_id]}
  @spec get_command(snowflake, snowflake) :: {:error, reason} | {:ok, [Command.t()]}
  def get_command(guild_id, command_id) do
    {:get, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}", nil, nil, nil}
    |> request()
    |> shape(Command)
  end

  @doc """
  Modify a guild command.

  Updates for guild commands will be available immediately.

  ## Options

  - `:name`  - `:string, min: 1, max: 32`
  - `:description` - `:string, min: 1, max: 100`
  - `:options`  - `{:array, CommandOption}`
  - `:default_permission`  - `:boolean, default: true` - whether the command is enabled by default when the app is added to a guild

  ## Examples

      iex> Remedy.API.modify_command(guild_id, good_command_id, {name: "new_name"})
      {:ok, %Command{}}

      iex> Remedy.API.modify_command(guild_id, bad_command_id, {name: "new_name"})
      {:error, reason}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "PATCH"
  @doc route: "/applications/:application_id/guilds/:guild_id/commands/:command_id"
  @unsafe {:modify_command, [:guild_id, :command_id, :opts]}
  @spec modify_command(snowflake, snowflake, opts) :: {:error, reason} | {:ok, Command.t()}
  def modify_command(guild_id, command_id, opts) do
    data = %{}

    types = %{
      name: :string,
      description: :string,
      options: {:array, CommandOption},
      default_permission: :boolean
    }

    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:patch, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}", nil, nil, body}
    |> request()
    |> shape(Command)
  end

  @doc """
  Delete a guild command.

  ## Examples

      iex> Remedy.API.delete_command(guild_id, good_command_id)
      {:ok, %{}}

      iex> Remedy.API.delete_command(guild_id, bad_command_id)
      {:error, reason}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "DELETE"
  @doc route: "/applications/:application_id/guilds/:guild_id/commands/:command_id"
  @unsafe {:delete_command, [:guild_id, :command_id]}
  @spec delete_command(snowflake, snowflake) :: {:error, reason} | :ok
  def delete_command(guild_id, command_id) do
    {:delete, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}", nil, nil, nil}
    |> request()
    |> shape()
  end

  @doc """
  Overwrite the existing guild application commands on the specified guild.

  This action will:
  - Create any command that was provided and did not already exist
  - Update any command that was provided and already existed if its configuration changed
  - Delete any command that was not provided but already exists

  ## Options

  - `:commands`  - `{:array, Command}`

  ## Examples

      iex> Remedy.API.overwrite_commands(guild_id, {commands: [{name: "command", description: "my new command"}]})
      {:ok, [%Command{}]}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "PUT"
  @doc route: "/applications/:application_id/guilds/:guild_id/commands"
  @unsafe {:cast_commands, [:guild_id, :opts]}
  @spec cast_commands(snowflake, opts) :: {:error, reason} | :ok
  def cast_commands(guild_id, opts) do
    body = %{}

    types = %{
      commands: {:array, Command}
    }

    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {body, types}
      |> cast(params, keys)

    {:put, "/applications/#{bot_id()}/guilds/#{guild_id}/commands", nil, nil, body}
    |> request()
    |> shape(Command)
  end

  @doc """
  List the permissions for a all guild commands.

  ## Examples

      iex> Remedy.API.list_command_permissions(guild_id)
      {:ok, %CommandPermission{}}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/applications/:application_id/guilds/:guild_id/commands/permissions"
  @unsafe {:list_command_permissions, [:guild_id]}
  @spec list_command_permissions(snowflake) :: {:error, reason} | {:ok, [CommandPermission.t()]}
  def list_command_permissions(guild_id) do
    {:get, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/permissions", nil, nil, nil}
    |> request()
    |> shape(CommandPermission)
  end

  @doc """
  List the permissions for a specific guild command.

  ## Examples

      iex> Remedy.API.list_command_permission(guild_id, good_command_id)
      {:ok, %CommandPermission{}}

      iex> Remedy.API.list_command_permission(guild_id, bad_command_id)
      {:error, reason}

  """
  @doc section: :commands
  @doc since: "0.6.0"
  def list_command_permissions(guild_id, command_id) do
    {:get, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}/permissions", nil, nil, nil}
    |> request()
    |> shape(CommandPermission)
  end

  @doc """
  Cast permissions for a specific guild command.

  ## Options

  - `:permissions`  - `{:array, CommandPermission}`

  ## Examples

      iex> Remedy.API.cast_command_permissions(guild_id, good_command_id, permissions: [{id: "user_id", allow: true}])
      {:ok, %CommandPermission{}}



  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "PUT"
  @doc route: "/applications/:application_id/guilds/:guild_id/commands/:command_id/permissions"
  @unsafe {:cast_command_permissions, [:guild_id, :command_id, :opts]}
  @spec cast_command_permissions(snowflake, snowflake, opts) :: {:error, reason} | {:ok, [CommandPermission.t()]}
  def cast_command_permissions(guild_id, command_id, opts) do
    data = %{}
    types = %{permissions: {:array, CommandPermission}}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:put, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/#{command_id}/permissions", nil, nil, body}
    |> request()
    |> shape(CommandPermission)
  end

  @doc """
  Cast command permisisons for all guild commands.

  ## Options

  - `:permissions`  - `{:array, CommandPermission}`

  ## Examples

      iex> Remedy.API.cast_command_permissions(guild_id, good_command_id, permissions: [{id: "user_id", allow: true}])
      {:ok, %CommandPermission{}}



  """
  @doc section: :commands
  @doc since: "0.6.0"
  @doc method: "PUT"
  @doc route: "/applications/:application_id/guilds/:guild_id/commands/permissions"
  @unsafe {:cast_command_permissions, [:guild_id, :opts]}
  @spec cast_command_permissions(snowflake, opts) :: {:error, reason} | {:ok, [CommandPermission.t()]}
  def cast_command_permissions(guild_id, opts) do
    data = %{}
    types = %{permissions: {:array, CommandPermission}}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:put, "/applications/#{bot_id()}/guilds/#{guild_id}/commands/permissions", nil, nil, body}
    |> request()
    |> shape(CommandPermission)
  end

  ###############################################################################################################
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ### ░██╗░███╗░░██╗░████████╗░███████╗░██████╗░░░█████╗░░░█████╗░░████████╗░██╗░░█████╗░░███╗░░██╗░░██████╗░ ###
  ### ░██║░████╗░██║░╚══██╔══╝░██╔════╝░██╔══██╗░██╔══██╗░██╔══██╗░╚══██╔══╝░██║░██╔══██╗░████╗░██║░██╔════╝░ ###
  ### ░██║░██╔██╗██║░░░░██║░░░░█████╗░░░██████╔╝░███████║░██║░░╚═╝░░░░██║░░░░██║░██║░░██║░██╔██╗██║░╚█████╗░░ ###
  ### ░██║░██║╚████║░░░░██║░░░░██╔══╝░░░██╔══██╗░██╔══██║░██║░░██╗░░░░██║░░░░██║░██║░░██║░██║╚████║░░╚═══██╗░ ###
  ### ░██║░██║░╚███║░░░░██║░░░░███████╗░██║░░██║░██║░░██║░╚█████╔╝░░░░██║░░░░██║░╚█████╔╝░██║░╚███║░██████╔╝░ ###
  ### ░╚═╝░╚═╝░░╚══╝░░░░╚═╝░░░░╚══════╝░╚═╝░░╚═╝░╚═╝░░╚═╝░░╚════╝░░░░░╚═╝░░░░╚═╝░░╚════╝░░╚═╝░░╚══╝░╚═════╝░░ ###
  ### ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ###
  ###############################################################################################################

  @doc """
  Create a response to an interaction received from the gateway.

  ## Options

  - `:type`  - `:integer`
    - `1` - PONG, ACK a Ping
    - `4` - CHANNEL_MESSAGE_WITH_SOURCE, respond to an interaction with a message
    - `5` - DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE, ACK an interaction and edit a response later, the user sees a loading state
    - `6` - DEFERRED_UPDATE_MESSAGE, for components, ACK an interaction and edit the original message later; the user does not see a loading state
    - `7` - UPDATE_MESSAGE, for components, edit the message the component was attached to
    - `8` - APPLICATION_COMMAND_AUTOCOMPLETE_RESULT, respond to an autocomplete interaction with suggested choices
  - `:data` - `CallbackData`

  ## Examples

      iex> Remedy.API.create_response(interaction_id, interaction_token, opts)
      {:ok, %InteractionResponse{}}

  """
  @doc section: :interactions
  @doc since: "0.6.0"
  @doc method: "POST"
  @doc route: "/interactions/:interaction_id/:interaction_token/callback"
  @unsafe {:create_response, [:interaction_id, :interaction_token, :type, :data]}
  @spec create_response(snowflake, token, opts) :: {:error, reason} | {:ok, [Callback.t()]}
  def create_response(interaction_id, interaction_token, opts) do
    data = %{}
    types = %{type: :integer, data: CallbackData}
    keys = Map.keys(types)
    params = Enum.into(opts, %{})

    body =
      {data, types}
      |> cast(params, keys)

    {:post, "/interactions/#{interaction_id}/#{interaction_token}/callback", nil, nil, body}
    |> request()
  end

  @doc """
  Get the initial interaction response

  See `get_message/4` for more information.
  """

  ## {:get, "/webhooks/#{bot_id()}/#{interaction_token}/messages/@original", nil, nil, body}

  @doc section: :interactions
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/webhooks/:application_id/:interaction_token/messages/@original"
  @unsafe {:get_response, [:interaction_token]}
  @spec get_response(token, opts) :: {:error, reason} | {:ok, [Callback.t()]}
  def get_response(interaction_token, opts \\ []) do
    get_message(bot_id(), interaction_token, "@original", opts)
  end

  @doc """
  Modify the initial interaction response.

  See `modify_message/4` for more information.
  """

  ## {:patch, "/webhooks/#{bot_id()}/#{interaction_token}/messages/@original", nil, nil, nil}

  @doc section: :interactions
  @doc since: "0.6.0"
  @doc method: "PATCH"
  @doc route: "/webhooks/:application_id/:interaction_token/messages/@original"
  @unsafe {:modify_response, [:interaction_token, :opts]}
  @spec modify_response(token, opts) :: {:error, reason} | {:ok, [Callback.t()]}
  def modify_response(interaction_token, opts) do
    modify_message(bot_id(), interaction_token, "@original", opts)
  end

  @doc """
  Delete the initial interaction response.

  ## Options

  `:thread_id` - `Snowflake`

  See `delete_message/4` for more information.

  """

  ## {:delete, "/webhooks/#{bot_id()}/#{interaction_token}/messages/@original"}

  @doc section: :interactions
  @doc since: "0.6.0"
  @doc method: "DELETE"
  @doc route: "/webhooks/:application_id/:interaction_token/messages/@original"
  @unsafe {:delete_response, [:interaction_token, :opts]}
  @spec delete_response(token, opts) :: {:error, reason} | {:ok, [Message.t()]}
  def delete_response(interaction_token, opts) do
    delete_message(bot_id(), interaction_token, "@original", opts)
  end

  @doc """
  Create a followup message for an interaction.

  See `execute_webhook/3` for more information.

  """

  ## {:post, "/webhooks/#{bot_id()}/#{interaction_token}"}

  @doc section: :interactions
  @doc since: "0.6.0"
  @doc method: "POST"
  @doc route: "/webhooks/:application_id/:interaction_token"
  @unsafe {:create_followup, [:interaction_token, :opts]}
  @spec create_followup(token, opts) :: {:error, reason} | {:ok, [Message.t()]}
  def create_followup(interaction_token, opts) do
    execute_webhook(bot_id(), interaction_token, opts)
  end

  @doc """
  Get a followup message for an interaction.

  Does not support ephemeral messages.

  See `get_message/4` for more information.

  """

  ## {:get, "/webhooks/#{bot_id()}/#{interaction_token}/messsages/#{message_id}"}

  @doc section: :interactions
  @doc since: "0.6.0"
  @doc method: "GET"
  @doc route: "/webhooks/:application_id/:interaction_token/messages/:message_id"
  @unsafe {:get_followup, [:interaction_token, :message_id]}
  @spec get_followup(token, snowflake) :: {:error, reason} | {:ok, [Message.t()]}
  def get_followup(interaction_token, message_id) do
    get_message(bot_id(), interaction_token, message_id)
  end

  @doc """
  Modify a followup message for an interaction.

  See `modify_message/4` for more information.

  """

  ## {:patch, "/webhooks/#{bot_id()}/#{interaction_token}/messsages/#{message_id}", nil, nil, body}

  @doc section: :interactions
  @doc since: "0.6.0"
  @doc method: "PATCH"
  @doc route: "/webhooks/:application_id/:interaction_token/messages/:message_id"
  @unsafe {:modify_followup, [:interaction_token, :message_id, :opts]}
  @spec modify_followup(token, snowflake, opts) :: {:error, reason} | {:ok, [Message.t()]}
  def modify_followup(interaction_token, message_id, opts) do
    modify_message(bot_id(), interaction_token, message_id, opts)
  end

  @doc """
  Delete a followup message for an interaction.

  See `delete_message/4` for more information.

  """

  ## {:delete, "/webhooks/#{bot_id()}/#{interaction_token}/messsages/#{message_id}", nil, nil, nil}

  @doc section: :interactions
  @doc since: "0.6.0"
  @doc method: "DELETE"
  @doc route: "/webhooks/:application_id/:interaction_token/messages/:message_id"
  @unsafe {:delete_followup, [:interaction_token, :message_id]}
  @spec delete_followup(token, snowflake, opts) :: :ok | {:error, reason}
  def delete_followup(interaction_token, message_id, opts) do
    delete_message(bot_id(), interaction_token, message_id, opts)
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

  #############################################################################
  ##  Gets a gateway URL.
  ##
  ##  Used to be required for the websocket
  ##  since: "0.6.0"
  @doc false
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

  #############################################################################
  ##  Gets a gateway connection object.
  ##
  ##  Manually invoking this function will count towards your connection limit
  ##  since: "0.6.0"
  @doc false
  @unsafe {:get_gateway_bot, []}
  @spec get_gateway_bot :: {:error, reason} | {:ok, map}
  def get_gateway_bot do
    {:get, "/gateway/bot", nil, nil, nil}
    |> request()
  end

  #############################################################################
  ## Grab the bots ID from the Cache
  ##
  ## This is automatically applied to all applicable functions.
  @doc false
  @spec bot_id :: Snowflake.t()
  alias Remedy.Cache
  def bot_id, do: Cache.app().id()

  #############################################################################
  ## Build a request
  ##
  ## request({method, route, params, reason, body})
  ## since: "0.6.0"
  @spec request({any, any, any, any, any}) :: {:error, any} | {:ok, any}
  defp request({method, route, params, reason, %{valid?: true} = body}) do
    request({method, route, params, reason, apply_changes(body)})
  end

  defp request({method, route, %Changeset{valid?: true} = params, reason, body}) do
    request({method, route, apply_changes(params), reason, body})
  end

  defp request({_method, _route, _params, _reason, %Changeset{valid?: false} = bad_changeset}) do
    return_errors(bad_changeset)
  end

  defp request({_method, _route, %Changeset{valid?: false} = bad_changeset, _reason, _body}) do
    return_errors(bad_changeset)
  end

  defp request({method, route, params, reason, body}) do
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

  ############################################################################
  ## Directly use a schema to create opts.
  ##
  ## Example: You are editing a channel and have a modified channel schema
  ## from elsewhere in the application. Passing it here would change the schema
  ## into a keyword list of options.
  ##
  defp filter_schema_into_opts(schema) when is_struct(schema) do
    schema
    |> EctoMorph.deep_filter_by_schema_fields(schema[:__struct__], filter_not_loaded: true)
    |> Morphix.compactiform!()
    |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  ############################################################################
  ## Generic casting when objects are returned
  ##
  ## Shapes the data to the correct types discarding invalid fields.
  defp shape({:ok, ""}), do: :ok
  defp shape({:error, _return} = error), do: error
  defp shape({:error, _return} = error, _module), do: error
  defp shape({:ok, returns}, module) when is_list(returns), do: {:ok, for(r <- returns, into: [], do: shape(r, module))}
  defp shape({:ok, return}, module), do: {:ok, shape(return, module)}

  defp shape(%{} = params, module) when is_atom(module) do
    Morphix.stringmorphiform!(params)
    |> module.changeset()
    |> Ecto.Changeset.apply_changes()
  end

  defp shape(params, fields) do
    Enum.filter(params, fn {k, _v} -> k in fields end)
    |> Enum.into(for(d <- fields, into: %{}, do: {d, nil}))
    |> Morphix.compactiform!()
  end

  #############################################################################
  ## Unwraps the return tuple
  ##
  ## For @unsafe {:func, [args]} to be delegated to
  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, reason}), do: raise("#{inspect(reason)}")

  #############################################################################
  ## Custom Ecto Validation

  ## Validate at least one of the parameters is present.
  ##
  defp validate_at_least_one(changeset, fields, opts \\ [])

  defp validate_at_least_one(%{params: params} = changeset, fields, opts) when is_map(params) when is_list(fields) do
    presence_map =
      for field <- fields,
          into: %{},
          do: {to_string(field), to_string(field) in Map.keys(params)}

    validations =
      for field <- fields,
          into: [],
          do: {field, {:at_least_one, opts}}

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

  defp has_one_of?(presence_map) do
    case Enum.filter(presence_map, fn {_k, v} -> v == true end) do
      [] -> false
      [_ | _] -> true
    end
  end

  defp message(opts, key \\ :message, default) do
    Keyword.get(opts, key, default)
  end
end
