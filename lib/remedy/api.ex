defmodule Remedy.API do
  @moduledoc """
  Standard interface for the Discord API.

  The majority of the functions within this module are pulled directly from the Discord API. Some custom implementations are included.

  ## Ratelimits

  Discord imposes rate limits in various capacities. The functions in this module will respect those rate limits where possible. If required, a request will be held until it is allowed to be completed.

  ## Cache Interaction

  This module does not automagically interract with the cache.

  ## Return Values

  Items returned from the API are parsed to ensure the values of in the correct format and types.

  ## List vs Get?

  Functions in the discord API that return lists are randomly called either Get or List for some arbitrary reason. This is rectified so that all functions returning lists will start with the verb list.

  ## Edit vs Modify?

  The functions have been normalized to `:modify`.

  > Note: This one is anyones guess, just saying if I can pick or the other with a $2 mcmuffin in my hand. Discord can figure it out with 400 mil in the bank. I made them all `:modify` because its cuter.

  ## Permissions

  Any permissions a bot requires on a server to send a request is shown under the function.

  ## Intents

  If a privileged intent is required for a request to be completed, it is also shown under the function.

  ## Missing Functions

  The following functions were not migrated from Nostrum

  - `:get_user_dms`

  """

  import Remedy.ModelHelpers

  import Sunbake.Snowflake,
    only: [is_snowflake: 1],
    warn: false

  alias Remedy.API.Rest

  alias Remedy.Schema.{
    App,
    AuditLog,
    Channel,
    Guild,
    Message,
    Sticker,
    Thread,
    User
  }

  use Unsafe.Generator, handler: :unwrap, docs: false

  @type opts :: keyword()
  @type error :: any()
  @type limit :: integer()
  @type locator :: any
  @type snowflake :: Sunbake.Snowflake.t()
  @type reason :: String.t() | nil

  ### Discord API Proper
  ###
  ### Functions are ordered by their occurence within the discord API
  ### documentation to make it easier to track and insert new functions.
  ### They are automatically reordered for the documentation

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
  Gets the bot's OAuth2 application info.

  ## Examples

      iex> Remedy.API.get_application_information()
      {:ok, %Remedy.Schema.App{}

  """
  @spec get_current_bot_application_information :: {:error, any} | {:ok, App.t()}
  @unsafe {:get_current_bot_application_information, []}
  def get_current_bot_application_information do
    {:get, "/oauth2/applications/@me"}
    |> request()
    |> parse_get_current_bot_application_information()
  end

  defp parse_get_current_bot_application_information({:error, _reason} = error), do: error
  defp parse_get_current_bot_application_information({:ok, bot}), do: {:ok, App.new(bot)}

  @doc """
  Gets the authorization information for the Bot.

  > This is currently unused by any of the connections employed by Remedy and is included for completeness only.

  ## Examples

      iex> Remedy.API.get_current_authorization_information()
      {:error, {401, 50001, "Missing Access"}}

  """
  @spec get_current_authorization_information() :: {:error, any} | {:ok, any}
  @unsafe {:get_current_authorization_information, []}
  def get_current_authorization_information do
    {:get, "/oauth2/@me"} |> request()
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
  Get an audit log.

  ## Query Options

  - `:user_id` - filter the log for actions made by a user.
  - `:action_type` - the type of audit log event
  - `:before` - filter the log before a certain entry id
  - `:limit` - how many entries are returned (default 50, minimum 1, maximum 100)

  ## Examples

      iex> Remedy.API.get_guild_audit_log(872417560094732328)
      {:ok, %Remedy.Schema.AuditLog{}}

      iex> Remedy.API.get_guild_audit_log(123)
      {:error, {403, 10004, "Unknown Guild"}}

  """
  @spec get_guild_audit_log(snowflake | Guild.t(), opts) :: {:error, any} | {:ok, AuditLog.t()}
  @unsafe {:get_guild_audit_log, [1, 2]}
  def get_guild_audit_log(guild_id, opts \\ [])
  def get_guild_audit_log(%Guild{id: id}, opts), do: get_guild_audit_log(id, opts)

  def get_guild_audit_log(guild_id, opts) when is_snowflake(guild_id) do
    {:get, "/guilds/#{guild_id}/audit-logs"}
    |> request(%{}, opts, nil)
    |> parse_get_guild_audit_log(guild_id)
  end

  defp parse_get_guild_audit_log({:error, _reason} = error, _guild_id), do: error

  defp parse_get_guild_audit_log({:ok, audit_log}, guild_id) do
    {:ok,
     audit_log
     |> AuditLog.new()
     |> AuditLog.update(%{guild_id: guild_id})}
  end

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

      iex> {:ok, channel} = Remedy.API.get_channel(872417560094732331)
      ...> channel.id
      872417560094732331

  """

  @spec get_channel(snowflake | Channel.t()) :: {:error, any} | {:ok, Channel.t()}
  @unsafe {:get_channel, [:channel_id]}
  def get_channel(channel_id)
  def get_channel(%Channel{id: channel_id}), do: get_channel(channel_id)

  def get_channel(channel_id) when is_integer(channel_id) do
    {:get, "/channels/#{channel_id}"}
    |> request()
    |> parse_get_channel()
  end

  defp parse_get_channel({:error, _reason} = error), do: error
  defp parse_get_channel({:ok, channel}), do: {:ok, Channel.new(channel)}

  @doc """
  Modifies a channel's settings.

  ## Permissions

  - `MANAGE_CHANNEL`

  ## Events

  - `:CHANNEL_UPDATE`.

  ## Options

  - `:name` (string) - 2-100 character channel name
  - `:position` (integer) - the position of the channel in the left-hand listing
  - `:topic` (string) - 0-1024 character channel topic
  - `:nsfw` (boolean) - if the channel is nsfw
  - `:bitrate` (integer) - the bitrate (in bits) of the voice channel; 8000 to 96000 (128000 for VIP servers)
  - `:user_limit` (integer)  - the user limit of the voice channel; 0 refers to no limit, 1 to 99 refers to a user limit
  - `:permission_overwrites` (list of `t:Remedy.Schema.Overwrite.t/0` or equivalent map) - channel or category-specific permissions
  - `:parent_id` - id of the new parent category for a channel

  ## Examples

  iex> Remedy.API.modify_channel(41771983423143933, name: "elixir-remedy", topic: "remedy discussion")
  {:ok, %Remedy.Schema.Channel{id: 41771983423143933, name: "elixir-remedy", topic: "remedy discussion"}}


  """

  ## to add: modify_guild_channel, modify_group_dm, modify_thread

  @spec modify_channel(snowflake, map(), reason) :: {:error, any} | {:ok, Channel.t()}

  @doc since: "0.6.0"
  @unsafe {:modify_channel, [:channel_id, :opts, :reason]}
  def modify_channel(channel_id, opts, reason \\ nil)

  def modify_channel(channel_id, opts, reason) do
    {:patch, "/channels/#{channel_id}"}
    |> request(opts, reason)
    |> parse_modify_channel()
  end

  defp parse_modify_channel({:error, _reason} = error), do: error
  defp parse_modify_channel({:ok, %{id: nil}}), do: {:error, "Request Failed"}
  defp parse_modify_channel({:ok, %{id: _id} = channel}), do: {:ok, Channel.new(channel)}

  @doc """
  Modify a group DM.

  This function validates the options before passing them to `Remedy.API.modify_channel/3`

  ## Events:

  - `:CHANNEL_UPDATE`

  ## Examples

      iex> Remedy.API.modify_group_dm(872417560094732331, [{:name, "hello"}], "felt like it")
      {:ok, %Channel{}}

  """

  @modify_group_dm_params %{name: nil, icon: nil}
  @spec modify_group_dm(Channel.t() | snowflake, keyword(), nil | binary) :: {:error, any} | {:ok, Channel.t()}

  @unsafe {:modify_group_dm, [:channel_id, :opts, :reason]}
  def modify_group_dm(channel_id, opts, reason \\ nil)
  def modify_group_dm(%Channel{id: channel_id}, opts, reason), do: modify_group_dm(channel_id, opts, reason)
  def modify_group_dm(%{channel_id: channel_id}, opts, reason), do: modify_group_dm(channel_id, opts, reason)

  def modify_group_dm(channel_id, opts, reason) do
    modify_channel(channel_id, clean_map(@modify_group_dm_params, opts), reason)
  end

  @doc """
  Modify a Text Channel.

  This function validates the options before passing them to `Remedy.API.modify_channel/3`

  ## Permissions

  - `MANAGE_CHANNELS`
  - `MANAGE_ROLES` (If modifying permission overwrites)

  ## Events:

  - `:CHANNEL_UPDATE`

  ## Examples

  iex> Remedy.API.modify_group_dm(872417560094732331, [{:name, "hello"}], "felt like it")
  {:ok, %Channel{}}

  """

  @modify_text_channel_params %{
    name: nil,
    type: nil,
    position: nil,
    topic: nil,
    nsfw: nil,
    rate_limit_per_user: nil,
    permission_overwrites: nil,
    parent_id: nil,
    default_auto_archive_duration: nil
  }

  @unsafe {:modify_text_channel, [:channel_id, :opts, :reason]}
  @spec modify_text_channel(Channel.t() | snowflake, opts, reason) :: {:error, any} | {:ok, Remedy.Schema.Channel.t()}
  def modify_text_channel(channel_id, opts, reason \\ nil)
  def modify_text_channel(%Channel{id: channel_id}, opts, reason), do: modify_text_channel(channel_id, opts, reason)
  def modify_text_channel(%{channel_id: channel_id}, opts, reason), do: modify_text_channel(channel_id, opts, reason)

  def modify_text_channel(channel_id, opts, reason) do
    modify_channel(channel_id, clean_map(@modify_text_channel_params, opts), reason)
  end

  @doc """
  Modify a Voice Channel.

  This function validates the options before passing them to `Remedy.API.modify_channel/3`

  ## Permissions

  - `MANAGE_CHANNELS`
  - `MANAGE_ROLES` (If modifying permission overwrites)

  ## Events:

  - `:CHANNEL_UPDATE`

  ## Examples

      iex> Remedy.API.voice_channel(872417560094732331, [{:name, "hello"}], "felt like it")
      {:ok, %Channel{}}

  """

  @modify_voice_channel_params %{
    name: nil,
    position: nil,
    bitrate: nil,
    user_limit: nil,
    permission_overwrites: nil,
    parent_id: nil,
    rtc_region: nil,
    video_quality_mode: nil,
    default_auto_archive_duration: nil
  }

  @unsafe {:modify_voice_channel, [:channel_id, :opts, :reason]}
  def modify_voice_channel(channel_id, opts, reason \\ nil)
  def modify_voice_channel(%Channel{id: channel_id}, opts, reason), do: modify_voice_channel(channel_id, opts, reason)
  def modify_voice_channel(%{channel_id: channel_id}, opts, reason), do: modify_voice_channel(channel_id, opts, reason)

  def modify_voice_channel(channel_id, opts, reason) do
    modify_channel(channel_id, clean_map(@modify_voice_channel_params, opts), reason)
  end

  @doc """
  Modify a News Channel.

  This function validates the options before passing them to `Remedy.API.modify_channel/3`

  ## Permissions

  - `MANAGE_CHANNELS`
  - `MANAGE_ROLES` (If modifying permission overwrites)

  ## Events:

  - `:CHANNEL_UPDATE`

  ## Examples

      iex> Remedy.API.modify_news_channel(872417560094732331, [{:name, "hello"}], "felt like it")
      {:ok, %Channel{}}

  """

  @modify_news_channel_params %{
    name: nil,
    type: nil,
    position: nil,
    topic: nil,
    nsfw: nil,
    permission_overwrites: nil,
    parent_id: nil,
    default_auto_archive_duration: nil
  }

  @unsafe {:modify_news_channel, [:channel_id, :opts, :reason]}
  def modify_news_channel(channel_id, opts, reason \\ nil)
  def modify_news_channel(%Channel{id: channel_id}, opts, reason), do: modify_news_channel(channel_id, opts, reason)
  def modify_news_channel(%{channel_id: channel_id}, opts, reason), do: modify_news_channel(channel_id, opts, reason)

  def modify_news_channel(channel_id, opts, reason) do
    modify_channel(channel_id, clean_map(@modify_news_channel_params, opts), reason)
  end

  @doc """
  Modify thread.

  This function validates the options before passing them to `Remedy.API.modify_channel/3`

  ## Permissions

  - `MANAGE_THREADS`
  - `SEND_MESSAGES` (If modifying permission overwrites)

  ## Events:

  - `:THREAD_UPDATE`

  ## Examples

      iex> Remedy.API.modify_group_dm(872417560094732331, [{:name, "hello"}], "felt like it")
      {:ok, %Channel{}}


  """

  @modify_thread_params %{name: nil, archived: nil, auto_archive_duration: nil}

  @unsafe {:modify_thread, [:channel_id, :opts, :reason]}
  def modify_thread(channel_id, opts, reason \\ nil)
  def modify_thread(%Thread{id: channel_id}, opts, reason), do: modify_thread(channel_id, opts, reason)
  def modify_thread(%{channel_id: channel_id}, opts, reason), do: modify_thread(channel_id, opts, reason)

  def modify_thread(channel_id, opts, reason) do
    modify_channel(channel_id, clean_map(@modify_thread_params, opts), reason)
  end

  def modify_thread_test(opts) do
    clean_map(@modify_thread_params, opts)
  end

  def modify_thread_test() do
    @modify_thread_params |> flatten()
  end

  @doc """
  Deletes a channel.

  An optional `reason` can be provided for the guild audit log.

  ## Permissions

  - `MANAGE_CHANNELS`

  ## Events

  - `:CHANNEL_DELETE`

  ## Examples

  iex> Remedy.API.delete_channel(421533712753360896)
  {:ok, %Remedy.Schema.Channel{id: 421533712753360896}}

  iex> Remedy.API.delete_channel(123)

  """
  @spec delete_channel(snowflake) :: {:error, any} | {:ok, map}

  @unsafe {:delete_channel, [:channel_id]}
  def delete_channel(channel_id)

  def delete_channel(channel_id) do
    {:delete, "/channels/#{channel_id}"}
    |> request()
    |> parse_delete_channel()
  end

  defp parse_delete_channel({:error, _reason} = error), do: error

  defp parse_delete_channel({:ok, channel}) do
    {:ok,
     channel
     |> Channel.new()}
  end

  @doc """
  Retrieves a channel's messages.

  ## Permissions

  - `VIEW_CHANNEL`
  - `READ_MESSAGE_HISTORY`

  ## Options

  - `:before`*
  - `:after`*
  - `:around`*
  - `:limit`

  > * Only one may be provided.

  ## Helpers

  - `Remedy.API.list_messages_before/3`
  - `Remedy.API.list_messages_after/3`
  - `Remedy.API.list_messages_around/3`

  ## Examples

      iex> Remedy.API.list_messages(872417560094732331, [{:before, 882781809908256789}, {:limit, 1}])
      {:ok, [%Message{id: 882681855315423292}]}

  """
  @spec list_messages(snowflake, keyword()) :: {:error, any} | {:ok, list}

  @doc since: "0.6"
  @unsafe {:list_messages, [:channel_id, :opts]}
  def list_messages(channel_id, opts \\ []) do
    body = Enum.into(opts, %{})

    {:get, "/channels/#{channel_id}/messages"}
    |> request(body)
    |> parse_list_messages()
  end

  defp parse_list_messages({:error, _reason} = error), do: error

  defp parse_list_messages({:ok, messages}) do
    messages = for m <- messages, into: [], do: Message.new(m)
    {:ok, messages}
  end

  @doc """
  List messages before a given message.
  """
  @unsafe {:list_messages_before, [:channel_id, :message_id, :limit]}
  @spec list_messages_before(snowflake, snowflake, limit) :: {:error, any} | {:ok, list}
  def list_messages_before(channel_id, message_id, limit \\ 50) do
    list_messages(channel_id, [{:before, message_id}, {:limit, limit}])
  end

  @doc """
  List messages after a given message.
  """
  @unsafe {:list_messages_after, [:channel_id, :message_id, :limit]}
  @spec list_messages_after(snowflake, snowflake, limit) :: {:error, any} | {:ok, list}
  def list_messages_after(channel_id, message_id, limit \\ 50) do
    list_messages(channel_id, [{:after, message_id}, {:limit, limit}])
  end

  @doc """
  List messages around a given message.
  """
  @unsafe {:list_messages_around, [:channel_id, :message_id, :limit]}
  @spec list_messages_around(snowflake, snowflake, limit) :: {:error, any} | {:ok, list}
  def list_messages_around(channel_id, message_id, limit \\ 50) do
    list_messages(channel_id, [{:around, message_id}, {:limit, limit}])
  end

  @doc """
  Retrieves a message from a channel.

  ## Permissions

  - 'VIEW_CHANNEL'
  - 'READ_MESSAGE_HISTORY'

  ## Examples

  iex> Remedy.API.get_channel_message(872417560094732331, 884355195277025321)
  {:ok, %Remedy.Schema.Message{}}

  """
  @unsafe {:get_channel_message, [:channel_id, :message_id]}
  @spec get_channel_message(snowflake, snowflake) :: {:error, any} | {:ok, Channel.t()}
  def get_channel_message(channel_id, message_id) do
    {:get, "/channels/#{channel_id}/messages/#{message_id}"}
    |> request()
    |> parse_get_channel_message()
  end

  defp parse_get_channel_message({:error, _reason} = error), do: error

  defp parse_get_channel_message({:ok, channel}) do
    {:ok,
     channel
     |> Message.new()}
  end

  @doc """
  Posts a message to a guild text or DM channel.

  ## Intents

  - `:VIEW_CHANNEL`
  - `:SEND_MESSAGES`
  - `:SEND_MESSAGES_TTS` (optional)

  ## Events

  - `t:Remedy.Gateway.Dispatch.message_create/0`.

  ## Options

    - `:content` (string) - the message contents (up to 2000 characters)
    - `:tts` (boolean) - true if this is a TTS message
    - `:file` (`t:Path.t/0` | map) - the path of the file being sent, or a map with the following keys if sending a binary from memory
    - `:name` (string) - the name of the file
    - `:body` (string) - binary you wish to send
    - `:embed` (`t:Remedy.Schema.Embed.t/0`) - embedded rich content
    - `:allowed_mentions` - See "Allowed mentions" below
    - `:message_reference` (`map`) - See "Message references" below

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
  def create_message(channel_id, opts \\ []) do
    opts = Enum.into(opts, %{})

    {:post, "/channels/#{channel_id}/messages"}
    |> request(opts)
  end

  @doc """
  Publish a message in a news channel.

  This will propagate a message out to all followers of the channel.

  > This is known as "Crosspost Message" in the Discord API.
  """
  @doc since: "0.6.0"
  @spec publish_message(Remedy.Schema.Message.t()) :: {:error, any} | {:ok, any}
  @unsafe {:publish_message, 1}
  def publish_message(%Message{channel_id: channel_id, id: id}), do: publish_message(channel_id, id)

  def publish_message(channel_id, message_id) do
    {:post, "/channels/#{channel_id}/messages/#{message_id}/crosspost"}
    |> request()
    |> parse_publish_message()
  end

  defp parse_publish_message({:error, _reason} = error), do: error
  defp parse_publish_message({:ok, message}), do: {:ok, Message.new(message)}

  @doc """
  Creates a reaction for a message.

  ## Permissions

  - `VIEW_CHANNEL`
  - `READ_MESSAGE_HISTORY`
  - `ADD_REACTIONS` ()

  ## Examples

      iex> Remedy.API.create_reaction(123123123123, 321321321321,
      ...> %Remedy.Schema.Emoji{id: 43819043108, name: "foxbot"}
      ...> )
      :ok

      iex> Remedy.API.create_reaction(123123123123, 321321321321, "\xF0\x9F\x98\x81")



  """
  @unsafe {:create_reaction, 3}
  def create_reaction(channel_id, message_id, emoji) do
    {:put, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me"}
    |> request()
  end

  @doc """
  Deletes a reaction the bot has made for the message.

  ## Permissions

  - `VIEW_CHANNEL`
  - `READ_MESSAGE_HISTORY`

  ## Events

  - `:MESSAGE_REACTION_REMOVE`

  ## Examples

      iex> Remedy.API.delete_own_reaction(123, 123, 123)
      {:ok}

  """
  @unsafe {:delete_own_reaction, 3}
  def delete_own_reaction(channel_id, message_id, emoji) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me"}
    |> request()
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

  @unsafe {:delete_user_reaction, 4}
  def delete_user_reaction(channel_id, message_id, emoji, user_id) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/#{user_id}"}
    |> request()
  end

  @doc """
  Gets all users who reacted with an emoji.

  This endpoint requires the `VIEW_CHANNEL` and `READ_MESSAGE_HISTORY` permissions.

  If successful, returns `{:ok, users}`. Otherwise, returns `t:Remedy.API.error/0`.

  See `create_reaction/3` for similar examples.
  """

  @unsafe {:get_creactions, 3}
  def get_reactions(channel_id, message_id, emoji) do
    {:get, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}"}
    |> request()
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


  """
  @unsafe {:delete_all_reactions, 2}
  def delete_all_reactions(channel_id, message_id) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions"}
    |> request()
  end

  @doc """
  Deletes all reactions of a given emoji from a message.

  ## Permissions

  - `MANAGE_MESSAGES`

  ## Events

  - `:MESSAGE_REACTION_REMOVE_EMOJI`

  If successful, returns `{:ok}`. Otherwise, returns `t:Remedy.API.error/0`.

  See `create_reaction/3` for similar examples.
  """

  @unsafe {:delete_all_reactions_for_emoji, 3}
  def delete_all_reactions_for_emoji(channel_id, message_id, emoji) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}"}
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
      {:ok}

      iex> Remedy.API.modify_message(889614079830925352, 1894013840914098, "hello world!")
      {:ok}


  """
  @doc since: "0.6.0"
  @unsafe {:modify_message, 2}
  def modify_message(channel_id, message_id) do
    {:patch, "/channels/#{channel_id}/messages/#{message_id}"}
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
  @unsafe {:delete_message, 2}
  def delete_message(channel_id, message_id) do
    {:delete, "/channels/#{channel_id}/messages/#{message_id}"}
    |> request()
  end

  @doc """
  Deletes multiple messages from a channel.

  `messages` is a list of `Remedy.Schema.Message.id` that you wish to delete.
  When given more than 100 messages, this function will chunk the given message
  list into blocks of 100 and send them off to the API. It will stop deleting
  on the first error that occurs. Keep in mind that deleting thousands of
  messages will take a pretty long time and it may be proper to just delete
  the channel you want to bulk delete in and recreate it.

  This method can only delete messages sent within the last two weeks.
  `Filter` is an optional parameter that specifies whether messages sent over
  two weeks ago should be filtered out; defaults to `true`.
  """

  @unsafe {:bulk_delete_messages, 1}
  def bulk_delete_messages(channel_id) do
    {:post, "/channels/#{channel_id}/messages/bulk-delete"}
    |> request()
  end

  @doc """
  Edit the permission overwrites for a user or role.

  Role or user to overwrite is specified by `overwrite_id`.

  `permission_info` is a map with the following keys:
   - `type` - Required; `member` if editing a user, `role` if editing a role.
   - `allow` - Bitwise value of allowed permissions.
   - `deny` - Bitwise value of denied permissions.
   - `type` - `member` if editing a user, `role` if editing a role.

  An optional `reason` can be provided for the audit log.

   `allow` and `deny` are defaulted to `0`, meaning that even if you don't
   specify them, they will override their respective former values in an
   existing overwrite.

  """

  @unsafe {:modify_channel_permissions, 2}
  def modify_channel_permissions(channel_id, overwrite_id) do
    {:put, "/channels/#{channel_id}/permissions/#{overwrite_id}"}
    |> request()
  end

  @doc """
  Gets a list of invites for a channel.

  This endpoint requires the 'VIEW_CHANNEL' and 'MANAGE_CHANNELS' permissions.

  If successful, returns `{:ok, invite}`. Otherwise, returns a
  `t:Remedy.API.error/0`.

  ## Examples

      iex> Remedy.API.get_channel_invites(43189401384091)
      {:ok, [%Remedy.Schema.Invite{}]}

  """

  @unsafe {:get_channel_invites, 1}
  def get_channel_invites(channel_id) do
    {:get, "/channels/#{channel_id}/invites"}
    |> request()
  end

  @doc """
  Creates an invite for a guild channel.

  An optional `reason` can be provided for the audit log.

  This endpoint requires the `CREATE_INSTANT_INVITE` permission.

  If successful, returns `{:ok, invite}`. Otherwise, returns a `t:Remedy.API.error/0`.

  ## Options

    - `:max_age` (integer) - duration of invite in seconds before expiry, or 0 for never.
      (default: `86400`)
    - `:max_uses` (integer) - max number of uses or 0 for unlimited.
      (default: `0`)
    - `:temporary` (boolean) - Whether the invite should grant temporary
      membership. (default: `false`)
    - `:unique` (boolean) - used when creating unique one time use invites.
      (default: `false`)

  ## Examples

      iex> Remedy.API.create_channel_invite(41771983423143933)
      {:ok, Remedy.Schema.Invite{}}

      iex> Remedy.API.create_channel_invite(41771983423143933, max_uses: 20)
      {:ok, %Remedy.Schema.Invite{}}

  """

  @unsafe {:create_channel_invite, 1}
  def create_channel_invite(channel_id) do
    {:post, "/channels/#{channel_id}/invites"}
    |> request()
  end

  @doc """
  Delete a channel permission for a user or role.

  Role or user overwrite to delete is specified by `channel_id` and `overwrite_id`.
  An optional `reason` can be given for the audit log.
  """

  @unsafe {:delete_channel_permissions, 2}
  def delete_channel_permission(channel_id, overwrite_id) do
    {:delete, "/channels/#{channel_id}/permissions/#{overwrite_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:follow_news_channel, 1}
  def follow_news_channel(channel_id) do
    {:post, "/channels/#{channel_id}/followers"}
    |> request()
  end

  @doc """
  Triggers the typing indicator.
  """
  @unsafe {:start_typing, 1}
  def start_typing(channel_id) do
    {:post, "/channels/#{channel_id}/typing"}
    |> request()
  end

  @doc """
  Retrieves all pinned messages from a channel.

  ## Permissions

  - 'VIEW_CHANNEL'
  - 'READ_MESSAGE_HISTORY'

  ## Examples

      iex> Remedy.API.get_pinned_messages(43189401384091)

  """
  @doc since: "0.6.0"
  @unsafe {:list_pinned_messages, 1}
  def list_pinned_messages(channel_id) do
    {:get, "/channels/#{channel_id}/pins"}
    |> request()
  end

  @doc """
  Pins a message in a channel.

  ## Permissions

  - 'VIEW_CHANNEL'
  - 'READ_MESSAGE_HISTORY'
  - 'MANAGE_MESSAGES'

  - `:MESSAGE_UPDATE`
  - `:CHANNEL_PINS_UPDATE`

  ## Examples

      iex> Remedy.API.add_pinned_channel_message(43189401384091, 18743893102394)

  """

  @unsafe {:pin_message, 2}
  def pin_message(channel_id, message_id) do
    {:put, "/channels/#{channel_id}/pins/#{message_id}"}
    |> request()
  end

  @doc """
  Unpins a message in a channel.

  ## Permissions

  - 'VIEW_CHANNEL'
  - 'READ_MESSAGE_HISTORY'
  - 'MANAGE_MESSAGES'

  ## Events

  - `:MESSAGE_UPDATE`
  - `:CHANNEL_PINS_UPDATE`

  ## Examples

      iex>


  """

  @unsafe {:unpin_message, 2}
  def unpin_message(channel_id, message_id) do
    {:delete, "/channels/#{channel_id}/pins/#{message_id}"}
    |> request()
  end

  @doc """
  add recipient to a group DM
  """
  @doc since: "0.6.0"
  @unsafe {:group_dm_add_recipient, 2}
  def group_dm_add_recipient(channel_id, user_id) do
    {:put, "/channels/#{channel_id}/recipients/#{user_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:group_dm_remove_recipient, 2}
  def group_dm_remove_recipient(channel_id, user_id) do
    {:delete, "/channels/#{channel_id}/recipients/#{user_id}"}
    |> request()
  end

  @doc """
  Starts a thread.
  """

  @doc since: "0.6.0"
  @unsafe {:start_thread_with_message, 2}
  def start_thread_with_message(channel_id, message_id) do
    {:post, "/channels/#{channel_id}/messages/#{message_id}/threads"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:start_thread_without_message, 1}
  def start_thread_without_message(channel_id) do
    {:post, "/channels/#{channel_id}/threads"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:join_thread, 1}
  def join_thread(channel_id) do
    {:put, "/channels/#{channel_id}/thread-members/@me"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:add_thread_member, 2}
  def add_thread_member(channel_id, user_id) do
    {:put, "/channels/#{channel_id}/thread-members/#{user_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:leave_thread, 1}
  def leave_thread(channel_id) do
    {:delete, "/channels/#{channel_id}/thread-members/@me"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:remove_thread_member, 2}
  def remove_thread_member(channel_id, user_id) do
    {:delete, "/channels/#{channel_id}/thread-members/#{user_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:list_thread_members, 1}
  def list_thread_members(channel_id) do
    {:get, "/channels/#{channel_id}/thread-members"}
    |> request()
  end

  @doc """
  List active threads.

  > Note: This can be requested on both the `/channels/` and the `/guilds/` routes. To specify which route is used, you should pass a full `%Guild{}` or `%Channel{}` object.

  """
  @doc since: "0.6.0"
  @unsafe {:list_active_threads, 1}
  @spec list_active_threads(Remedy.Schema.Channel.t() | Remedy.Schema.Guild.t()) ::
          {:error, any} | {:ok, any}
  def list_active_threads(%Guild{id: guild_id}) do
    {:get, "/guilds/#{guild_id}/threads/active"}
    |> request()
  end

  @doc since: "0.6.0"

  def list_active_threads(%Channel{id: channel_id}) do
    {:get, "/channels/#{channel_id}/threads/active"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:list_public_archived_threads, 1}
  def list_public_archived_threads(channel_id) do
    {:get, "/channels/#{channel_id}/threads/archived/public"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:list_private_archived_threads, 1}
  def list_private_archived_threads(channel_id) do
    {:get, "/channels/#{channel_id}/threads/archived/private"}
    |> request()
  end

  @doc since: "0.6.0"
  @unsafe {:list_joined_private_archived_threads, 1}
  def list_joined_private_archived_threads(channel_id) do
    {:get, "/channels/#{channel_id}/users/@me/threads/archived/private"}
    |> request()
  end

  ## Emoji

  @doc """
  Gets a list of emojis for a given guild.

  This endpoint requires the `MANAGE_EMOJIS` permission.

  If successful, returns `{:ok, emojis}`. Otherwise, returns `t:Remedy.API.error/0`.
  """
  @unsafe {:list_guild_emojis, 1}
  def list_guild_emojis(guild_id) do
    {:get, "/guilds/#{guild_id}/emojis"}
    |> request()
  end

  @doc """
  Gets an emoji for the given guild and emoji ids.

  This endpoint requires the `MANAGE_EMOJIS` permission.

  If successful, returns `{:ok, emoji}`. Otherwise, returns `t:Remedy.API.error/0`.
  """

  @unsafe {:get_guild_emoji, 2}
  def get_guild_emoji(guild_id, emoji_id) do
    {:get, "/guilds/#{guild_id}/emojis/#{emoji_id}"}
    |> request()
  end

  @doc """
  Creates a new emoji for the given guild.

  This endpoint requires the `MANAGE_EMOJIS` permission. It fires a
  `t:Remedy.Consumer.guild_emojis_update/0` event.

  An optional `reason` can be provided for the audit log.

  If successful, returns `{:ok, emoji}`. Otherwise, returns `t:Remedy.API.error/0`.

  ## Options

    - `:name` (string) - name of the emoji
    - `:image` (base64 data URI) - the 128x128 emoji image. Maximum size of 256kb
    - `:roles` list of  - roles for which this emoji will be whitelisted
    (default: [])

  `:name` and `:image` are always required.

  ## Examples

      iex> image = "data:image/png;base64,YXl5IGJieSB1IGx1a2luIDQgc3VtIGZ1az8="
      ...> Remedy.API.create_guild_emoji(43189401384091, name: "remedy", image: image, roles: [])

  """

  @unsafe {:create_guild_emoji, 1}
  def create_guild_emoji(guild_id) do
    {:post, "/guilds/#{guild_id}/emojis"}
    |> request()
  end

  @doc """
  Modify the given emoji.

  This endpoint requires the `MANAGE_EMOJIS` permission. It fires a
  `t:Remedy.Consumer.guild_emojis_update/0` event.

  An optional `reason` can be provided for the audit log.

  If successful, returns `{:ok, emoji}`. Otherwise, returns `t:Remedy.API.error/0`.

  ## Options

    - `:name` (string) - name of the emoji
    - `:roles` - roles to which this emoji will be whitelisted

  ## Examples

      iex> Remedy.API.modify_guild_emoji(43189401384091, 4314301984301, name: "elixir", roles: [])
      {:ok, %Remedy.Schema.Emoji{}}

  """
  @unsafe {:modify_guild_emoji, 2}
  def modify_guild_emoji(guild_id, emoji_id) do
    {:patch, "/guilds/#{guild_id}/emojis/#{emoji_id}"}
    |> request()
  end

  @doc """
  Deletes the given emoji.

  An optional `reason` can be provided for the audit log.

  This endpoint requires the `MANAGE_EMOJIS` permission. It fires a
  `t:Remedy.Consumer.guild_emojis_update/0` event.

  If successful, returns `{:ok}`. Otherwise, returns `t:Remedy.API.error/0`.
  """
  @unsafe {:delete_guild_emoji, 2}
  def delete_guild_emoji(guild_id, emoji_id) do
    {:delete, "/guilds/#{guild_id}/emojis/#{emoji_id}"}
    |> request()
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

  @doc since: "0.6.0"
  @unsafe {:create_guild, 1}
  def create_guild do
    {:post, "/guilds"}
    |> request()
  end

  @doc """
  Gets a guild.

  ## Examples

      iex> Remedy.API.get_guild(81384788765712384)
      {:ok, %Remedy.Schema.Guild{id: 81384788765712384}}

  """

  @unsafe {:get_guild, 1}
  def get_guild(guild_id) do
    {:get, "/guilds/#{guild_id}"}
    |> request()
  end

  @doc """
  Modifies a guild's settings.

  ## Permissions

  - `MANAGE_GUILD`

  ## Events

  - `:GUILD_UPDATE`

  ## Options

    - `:name` (string) - guild name
    - `:region` (string) - guild voice region id
    - `:verification_level` (integer) - verification level
    - `:default_message_notifications` (integer) - default message    notification level
    - `:explicit_content_filter` (integer) - explicit content filter level
    - `:afk_channel_id`  - id for afk channel
    - `:afk_timeout` (integer) - afk timeout in seconds
    - `:icon` (base64 data URI) - 128x128 jpeg image for the guild icon
    - `:owner_id`  - user id to transfer guild ownership to (must be owner)
    - `:splash` (base64 data URI) - 128x128 jpeg image for the guild splash (VIP only)
    - `:system_channel_id` - the id of the channel to which system messages are sent
    - `:rules_channel_id`  - the id of the channel that is used for rules in public guilds
    - `:public_updates_channel_id`  - the id of the channel where admins and moderators receive notices from Discord in public guilds

  ## Examples

      iex> Remedy.API.modify_guild(451824027976073216, name: "Nose Drum")
      {:ok, %Remedy.Schema.Guild{id: 451824027976073216, name: "Nose Drum", ...}}

  """
  @unsafe {:modify_guild, 1}
  def modify_guild(guild_id) do
    {:patch, "/guilds/#{guild_id}"}
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
    {:delete, "/guilds/#{guild_id}"}
    |> request()
  end

  @doc """
  Gets a list of guild channels.

  ## Examples

      iex> Remedy.API.get_guild_channels(81384788765712384)
      {:ok, [%Remedy.Schema.Channel{guild_id: 81384788765712384}]}

  """

  def get_guild_channels(guild_id) do
    {:get, "/guilds/#{guild_id}/channels"}
    |> request()
  end

  @doc """
  Creates a channel for a guild.

  ## Permissions

  - `MANAGE_CHANNELS`

  ## Events

  - `:CHANNEL_CREATE`

  ## Options

    - `:name` (string) - channel name (2-100 characters)
    - `:type` (integer) - the type of channel (See `Remedy.Schema.Channel`)
    - `:topic` (string) - channel topic (0-1024 characters)
    - `:bitrate` (integer) - the bitrate (in bits) of the voice channel (voice only)
    - `:user_limit` (integer) - the user limit of the voice channel (voice only)
    - `:permission_overwrites` (list of `t:Remedy.Schema.Overwrite.t/0` or equivalent map) - the channel's permission overwrites
    - `:parent_id`  - id of the parent category for a channel
    - `:nsfw` (boolean) - if the channel is nsfw

  ## Examples

      iex> Remedy.API.create_guild_channel(81384788765712384, name: "elixir-remedy", topic: "craig's domain")
      {:ok, %Remedy.Schema.Channel{guild_id: 81384788765712384}}

  """

  def create_guild_channel(guild_id) do
    {:post, "/guilds/#{guild_id}/channels"}
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

      iex> Remedy.API.modify_guild_channel_positions(279093381723062272, [%{id: 351500354581692420, position: 2}])
      {:ok}

      iex> Remedy.API.modify_guild_channel_positions(279093381723062272, [%{id: 351500354581692420, position: 2}])
      {:ok}

  """
  def modify_guild_channel_positions(guild_id) do
    {:patch, "/guilds/#{guild_id}/channels"}
    |> request()
  end

  @doc """
  Gets a guild member.

  ## Examples

      iex> Remedy.API.get_guild_member(4019283754613, 184937267485)

  """
  def get_guild_member(guild_id, user_id) do
    {:get, "/guilds/#{guild_id}/members/#{user_id}"}
    |> request()
  end

  @doc """
  Gets a list of a guild's members.

  ## Options

    - `:limit` (integer) - max number of members to return (1-1000) (default: 1)
    - `:after` (`t:Remedy.Schema.User.id/0`) - the highest user id in the previous page (default: 0)

  ## Examples

      iex>  Remedy.API.list_guild_members(41771983423143937, limit: 1)

  """
  def list_guild_members(guild_id) do
    {:get, "/guilds/#{guild_id}/members"}
    |> request()
  end

  @doc since: "0.6.0"
  def search_guild_members(guild_id) do
    {:get, "/guilds/#{guild_id}/members/search"}
    |> request()
  end

  @doc """
  Puts a user in a guild.

  ## Permissions

  - `CREATE_INSTANT_INVITE`
  - `MANAGE_NICKNAMES`*
  - `MANAGE_ROLES`*
  - `MUTE_MEMBERS`*
  - `DEAFEN_MEMBERS`*

  ## Events

  - `:GUILD_MEMBER_ADD`

  ## Options

    - `:access_token` (string) - the user's oauth2 access token
    - `:nick` (string) - value to set users nickname to
    - `:roles` (list of `t:Remedy.Schema.Guild.Role.id/0`) - array of role ids the member is assigned
    - `:mute` (boolean) - if the user is muted
    - `:deaf` (boolean) - if the user is deafened

  `:access_token` is always required.

  ## Examples

      iex> Remedy.API.add_guild_member(
      ...> 41771983423143937,
      ...> 18374719829378473,
      ...> access_token: "6qrZcUqja7812RVdnEKjpzOL4CvHBFG",
      ...> nick: "remedy",
      ...> roles: [431849301, 913809431])

  """

  def add_guild_member(guild_id, user_id) do
    {:put, "/guilds/#{guild_id}/members/#{user_id}"}
    |> request()
  end

  @doc """
  Modifies a guild member's attributes.

  ## Permissions

  - `MANAGE_NICKNAMES`
  - `MANAGE_ROLES`
  - `MUTE_MEMBERS`
  - `DEAFEN_MEMBERS`
  - `MOVE_MEMBERS`

  ## Events

  - `:GUILD_MEMBER_UPDATE`

  ## Options

  - `:nick` (string) - value to set users nickname to
  - `:roles`  - array of role ids the member is assigned
  - `:mute` (boolean) - if the user is muted
  - `:deaf` (boolean) - if the user is deafened
  - `:channel_id` - id of channel to move user to (if they are connected to voice)

  ## Examples

      iex> Remedy.API.modify_guild_member(41771983423143937, 637162356451, nick: "Remedy")
      {:ok}

  """

  def modify_guild_member(guild_id, user_id) do
    {:patch, "/guilds/#{guild_id}/members/#{user_id}"}
    |> request()
  end

  @doc """
  Modifies the nickname of the current user in a guild.

  ## Options

    - `:nick` (string) - value to set users nickname to

  ## Examples

      iex> Remedy.API.modify_nickname(41771983423143937, nick: "Remedy")
      {:ok, %{nick: "Remedy"}}

      iex>

  """
  def modify_nickname(guild_id, nickname) do
    {:patch, "/guilds/#{guild_id}/members/@me"}
    |> request(%{nick: nickname})
  end

  @doc """
  Adds a role to a member.

  Role to add is specified by `role_id`.
  User to add role to is specified by `guild_id` and `user_id`.
  An optional `reason` can be given for the audit log.
  """

  def add_guild_member_role(guild_id, user_id, role_id) do
    {:put, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}"}
    |> request()
  end

  @doc """
  Removes a role from a member.

  Role to remove is specified by `role_id`.
  User to remove role from is specified by `guild_id` and `user_id`.
  An optional `reason` can be given for the audit log.
  """

  def remove_guild_member_role(guild_id, user_id, role_id) do
    {:delete, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}"}
    |> request()
  end

  @doc """
  Removes a member from a guild.

  This event requires the `KICK_MEMBERS` permission. It fires a
  `t:Remedy.Consumer.guild_member_remove/0` event.

  An optional reason can be provided for the audit log with `reason`.

  If successful, returns `{:ok}`. Otherwise, returns a `t:Remedy.API.error/0`.

  ## Examples

      iex> Remedy.API.remove_guild_member(1453827904102291, 18739485766253)
      {:ok}

  """
  def remove_guild_member(guild_id, user_id) do
    {:delete, "/guilds/#{guild_id}/members/#{user_id}"}
    |> request()
  end

  @doc """
  Gets a list of users banned from a guild.

  Guild to get bans for is specified by `guild_id`.

  """
  @doc since: "0.6"
  def list_guild_bans(guild_id) do
    {:get, "/guilds/#{guild_id}/bans"}
    |> request()
  end

  @doc """
  Gets a ban object for the given user from a guild.
  """

  def get_guild_ban(guild_id, user_id) do
    {:get, "/guilds/#{guild_id}/bans/#{user_id}"}
    |> request()
  end

  @doc """
  Bans a user from a guild.

  User to delete is specified by `guild_id` and `user_id`.
  An optional `reason` can be specified for the audit log.
  """

  def create_guild_ban(guild_id, user_id) do
    {:put, "/guilds/#{guild_id}/bans/#{user_id}"}
    |> request()
  end

  @doc """
  Removes a ban for a user.

  User to unban is specified by `guild_id` and `user_id`.
  An optional `reason` can be specified for the audit log.
  """
  def remove_guild_ban(guild_id, user_id) do
    {:delete, "/guilds/#{guild_id}/bans/#{user_id}"}
    |> request()
  end

  @doc """
  Gets a guild's roles.

  If successful, returns `{:ok, roles}`. Otherwise, returns a `t:Remedy.API.error/0`.

  ## Examples

      iex>  Remedy.API.get_guild_roles(147362948571673)
      {:ok, [%Remedy.Schema.Role{}]}

  """
  @doc since: "0.6"
  def list_guild_roles(guild_id) do
    {:get, "/guilds/#{guild_id}/roles"}
    |> request()
  end

  @doc """
  Creates a guild role.

  An optional reason for the audit log can be provided via `reason`.

  This endpoint requires the `MANAGE_ROLES` permission. It fires a
  `t:Remedy.Consumer.guild_role_create/0` event.

  If successful, returns `{:ok, role}`. Otherwise, returns a `t:Remedy.API.error/0`.

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
  def create_guild_roles(guild_id) do
    {:post, "/guilds/#{guild_id}/roles"}
  end

  @doc """
  Reorders a guild's roles.

  This endpoint requires the `MANAGE_ROLES` permission. It fires multiple
  `t:Remedy.Consumer.guild_role_update/0` events.

  If successful, returns `{:ok, roles}`. Otherwise, returns a `t:Remedy.API.error/0`.

  `positions` is a list of maps that each map a role id with a position.

  ## Examples

      iex> Remedy.API.modify_guild_role_positions(41771983423143937, [%{id: 41771983423143936, position: 2}])

  """
  def modify_guild_role_positions(guild_id) do
    {:patch, "/guilds/#{guild_id}/roles"}
  end

  @doc """
  Modifies a guild role.

  This endpoint requires the `MANAGE_ROLES` permission. It fires a
  `t:Remedy.Consumer.guild_role_update/0` event.

  An optional `reason` can be specified for the audit log.

  If successful, returns `{:ok, role}`. Otherwise, returns a `t:Remedy.API.error/0`.

  ## Options

    - `:name` (string) - name of the role
    - `:permissions` (integer) - bitwise of the enabled/disabled permissions
    - `:color` (integer) - RGB color value (default: 0)
    - `:hoist` (boolean) - whether the role should be displayed separately in the sidebar
    - `:mentionable` (boolean) - whether the role should be mentionable

  ## Examples

      iex> Remedy.API.modify_guild_role(41771983423143937, 392817238471936, hoist: false, name: "foo-bar")

  """
  def modify_guild_role(guild_id, role_id) do
    {:patch, "/guilds/#{guild_id}/roles/#{role_id}"}
  end

  @doc """
  Deletes a role from a guild.

  An optional `reason` can be specified for the audit log.

  This endpoint requires the `MANAGE_ROLES` permission. It fires a
  `t:Remedy.Consumer.guild_role_delete/0` event.

  If successful, returns `{:ok}`. Otherwise, returns a `t:Remedy.API.error/0`.

  ## Examples

      iex> Remedy.API.delete_guild_role(41771983423143937, 392817238471936)

  """
  def delete_guild_role(guild_id, role_id) do
    {:delete, "/guilds/#{guild_id}/roles/#{role_id}"}
  end

  @doc """
  Gets the number of members that would be removed in a prune given `days`.

  This endpoint requires the `KICK_MEMBERS` permission.

  If successful, returns `{:ok, %{pruned: pruned}}`. Otherwise, returns a `t:Remedy.API.error/0`.

  ## Examples

      iex> Remedy.API.get_guild_prune_count(81384788765712384, 1)
      {:ok, %{pruned: 0}}

  """

  def get_guild_prune_count(guild_id) do
    {:get, "/guilds/#{guild_id}/prune"}
  end

  @doc """
  Begins a guild prune to prune members within `days`.

  An optional `reason` can be provided for the guild audit log.

  This endpoint requires the `KICK_MEMBERS` permission. It fires multiple
  `t:Remedy.Consumer.guild_member_remove/0` events.

  If successful, returns `{:ok, %{pruned: pruned}}`. Otherwise, returns a `t:Remedy.API.error/0`.

  ## Examples

      iex> Remedy.API.begin_guild_prune(81384788765712384, 1)
      {:ok, %{pruned: 0}}

  """

  def begin_guild_prune(guild_id) do
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

  If successful, returns `{:ok, invites}`. Otherwise, returns a `t:Remedy.API.error/0`.

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
  def get_guild_integrations(guild_id) do
    {:get, "/guilds/#{guild_id}/integrations"}
  end

  @doc """
  Deletes a guild integeration.

  Integration to delete is specified by `guild_id` and `integeration_id`.
  """
  def delete_guild_integration(guild_id, integration_id) do
    {:get, "/guilds/#{guild_id}/integrations/#{integration_id}"}
  end

  @doc since: "0.6.0"
  def get_guild_widget_settings(guild_id) do
    {:get, "/guilds/#{guild_id}/widget"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_widget(guild_id) do
    {:get, "/guilds/#{guild_id}/widget.json"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_vanity_url(guild_id) do
    {:get, "/guilds/#{guild_id}/vanity-url"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_widget_image(guild_id) do
    {:get, "/guilds/#{guild_id}/widget.png"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_welcome_screen(guild_id) do
    {:get, "/guilds/#{guild_id}/welcome-screen"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_guild_welcome_screen(guild_id) do
    {:patch, "/guilds/#{guild_id}/welcome-screen"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_current_user_voice_state(guild_id) do
    {:patch, "/guilds/#{guild_id}/voice-states/@me"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_user_voice_state(guild_id, user_id) do
    {:patch, "/guilds/#{guild_id}/voice-states/#{user_id}"}
    |> request()
  end

  ## Guild Template

  @doc since: "0.6.0"
  def get_guild_template(template_code) do
    {:get, "/guilds/templates/#{template_code}"}
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

  ## Invite

  @doc """
  Gets an invite by its `invite_code`.

  If successful, returns `{:ok, invite}`. Otherwise, returns a
  `t:Remedy.API.error/0`.

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
  `t:Remedy.API.error/0`.

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
    {:get, "/stickers/#{sticker_id}"}
    |> request()
    |> parse_get_sticker()
  end

  defp parse_get_sticker({:error, _reason} = error), do: error
  defp parse_get_sticker({:ok, sticker}), do: {:ok, Sticker.new(sticker)}

  @doc since: "0.6.0"
  def list_nitro_sticker_packs do
    {:get, "/sticker-packs"}
    |> request()
  end

  @doc since: "0.6.0"
  def list_guild_stickers(guild_id) do
    {:get, "/guilds/#{guild_id}/stickers"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_sticker(guild_id, sticker_id) do
    {:get, "/guilds/#{guild_id}/stickers/#{sticker_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def create_guild_sticker(guild_id, sticker_id) do
    {:post, "/guilds/#{guild_id}/stickers/#{sticker_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_guild_sticker(guild_id, sticker_id) do
    {:patch, "/guilds/#{guild_id}/stickers/#{sticker_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_guild_sticker(guild_id, sticker_id) do
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
  Gets info on the current user.

  If remedy's caching is enabled, it is recommended to use `Bot.get/0`
  instead of this function. This is because sending out an API request is much slower
  than pulling from our cache.

  If the request is successful, this function returns `{:ok, user}`, where
  `user` is remedy's `Remedy.Schema.User`. Otherwise, returns `{:error, reason}`.
  """
  @unsafe {:get_current_user, []}
  def get_current_user do
    {:get, "/users/@me"}
    |> request()
    |> parse_get_current_user()
  end

  defp parse_get_current_user({:error, _reason} = error), do: error
  defp parse_get_current_user({:ok, user}), do: {:ok, User.new(user)}

  @doc """
  Gets a user by its `t:Remedy.Schema.User.id/0`.

  If the request is successful, this function returns `{:ok, user}`, where
  `user` is a `Remedy.Schema.User`. Otherwise, returns `{:error, reason}`.
  """
  @unsafe {:get_user, [:user_id]}
  def get_user(user_id) do
    {:get, "/users/#{user_id}"}
    |> request()
    |> parse_get_user()
  end

  defp parse_get_user({:error, _reason} = error), do: error

  defp parse_get_user({:ok, user}) do
    {:ok,
     user
     |> User.new()}
  end

  @doc """
  Changes the username or avatar of the current user.

  ## Options

    - `:username` (string) - new username
    - `:avatar` (string) - the user's avatar as [avatar data](https://discord.com/developers/docs/resources/user#avatar-data)

  ## Examples

      iex> Remedy.API.modify_current_user(avatar: "data:image/jpeg;base64,YXl5IGJieSB1IGx1a2luIDQgc3VtIGZ1az8=")
      {:ok, %Remedy.Schema.User{}}
  """
  def modify_current_user do
    {:patch, "/users/@me"}
    |> request()
  end

  @doc """
  Gets a list of guilds the user is currently in.

  This endpoint requires the `guilds` OAuth2 scope.

  If successful, returns `{:ok, guilds}`. Otherwise, returns a `t:Remedy.API.error/0`.

  ## Options

    - `:before` - get guilds before this guild ID
    - `:after`  - get guilds after this guild ID
    - `:limit` (integer) - max number of guilds to return (1-100)

  ## Examples

      iex> Remedy.API.get_current_user_guilds(limit: 1)
      {:ok, [%Remedy.Schema.Guild{}]}

  """
  def get_current_user_guilds do
    {:get, "/users/@me/guilds"}
    |> request()
  end

  @doc """
  Leaves a guild.

  Guild to leave is specified by `guild_id`.
  """
  def leave_guild(guild_id) do
    {:delete, "/users/@me/guilds/#{guild_id}"}
    |> request()
  end

  @doc """
  Create a new DM channel with a user.

  If successful, returns `{:ok, dm_channel}`. Otherwise, returns a `t:Remedy.API.error/0`.

  ## Examples

      iex> Remedy.API.create_dm(150061853001777154)
      {:ok, %Remedy.Schema.Channel{type: 1}}

  """
  def create_dm do
    {:post, "/users/@me/channels"}
    |> request()
  end

  @doc """
  Creates a new group DM channel.

  If successful, returns `{:ok, group_dm_channel}`. Otherwise, returns a `t:Remedy.API.error/0`.

  `access_tokens` are user oauth2 tokens. `nicks` is a map that maps a user id
  to a nickname.

  ## Examples

      iex> Remedy.API.create_group_dm(["6qrZcUqja7812RVdnEKjpzOL4CvHBFG"], %{41771983423143937 => "My Nickname"})
      {:ok, %Remedy.Schema.Channel{type: 3}}

  """
  def create_group_dm do
    {:post, "/users/@me/channels"}
    |> request()
  end

  @doc """
  Gets a list of user connections.
  """

  def get_user_connections do
    {:get, "/users/@me/connections"}
    |> request()
  end

  ## Voice
  @doc """
  Gets a list of voice regions.
  """

  def list_voice_regions do
    {:get, "/voice/regions"}
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

  @doc """
  Executes a slack webhook.

  ## Parameters
    - `webhook_id` - Id of the webhook to execute.
    - `webhook_token` - Token of the webhook to execute.
  """

  def execute_slack_webhook(webhook_id, webhook_token) do
    {:post, "/webhooks/#{webhook_id}/#{webhook_token}/slack"}
    |> request()
  end

  @doc """
  Executes a github webhook.

  ## Parameters
    - `webhook_id` - Id of the webhook to execute.
    - `webhook_token` - Token of the webhook to execute.
  """
  def execute_github_webhook(webhook_id, webhook_token) do
    {:post, "/webhooks/#{webhook_id}/#{webhook_token}/github"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_webhook_message(webhook_id, webhook_token, message_id) do
    {:get, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_webhook_message(webhook_id, webhook_token, message_id) do
    {:patch, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_webhook_message(webhook_id, webhook_token, message_id) do
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
  alias Remedy.Cache.DiscordBot

  @doc """
  Fetch all global commands.

  ## Parameters
  - `application_id`: Application ID for which to search commands.
    If not given, this will be fetched from `Me`.

  ## Return value
  A list of ``ApplicationCommand``s on success. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#applicationcommand

  ## Example

      iex> Remedy.API.get_global_application_commands
      {:ok, [%{application_id: "455589479713865749"}]}

  """

  def get_global_application_commands do
    {:get, "/applications/#{DiscordBot.id()}/commands"}
    |> request()
  end

  @doc """
  Create a new global application command.

  The new command will be available on all guilds in around an hour.
  If you want to test commands, use `create_guild_application_command/2` instead,
  as commands will become available instantly there.
  If an existing command with the same name exists, it will be overwritten.

  ## Parameters
  - `application_id`: Application ID for which to create the command.
    If not given, this will be fetched from `Me`.
  - `command`: Command configuration, see the linked API documentation for reference.

  ## Return value
  The created command. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#create-global-application-command

  ## Example

      iex>  Remedy.API.create_application_command(%{name: "edit", description: "ed, man! man, ed", options: []})
      {:ok, %Remedy.Schema.Command{}}

  """
  def create_global_application_command do
    {:post, "/applications/#{DiscordBot.id()}/commands"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_global_application_command(command_id) do
    {:get, "/applications/#{DiscordBot.id()}/commands/#{command_id}"}
    |> request()
  end

  @doc """
  Update an existing global application command.

  The updated command will be available on all guilds in around an hour.

  ## Parameters
  - `application_id`: Application ID for which to edit the command.
    If not given, this will be fetched from `Me`.
  - `command_id`: The current snowflake of the command.
  - `command`: Command configuration, see the linked API documentation for reference.

  ## Return value
  The updated command. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#edit-global-application-command
  """
  def modify_global_application_command(command_id) do
    {:patch, "/applications/#{DiscordBot.id()}/commands/#{command_id}"}
    |> request()
  end

  @doc """
  Delete an existing global application command.

  ## Parameters
  - `application_id`: Application ID for which to create the command.
    If not given, this will be fetched from `Me`.
  - `command_id`: The current snowflake of the command.
  """
  def delete_global_application_command(command_id) do
    {:delete, "/applications/#{DiscordBot.id()}/commands/#{command_id}"}
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
  - `application_id`: Application ID for which to overwrite the commands.
    If not given, this will be fetched from `Me`.
  - `commands`: List of command configurations, see the linked API documentation for reference.

  ## Return value
  Updated list of global application commands. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#bulk-overwrite-global-application-commands
  """
  def bulk_overwrite_global_application_commands do
    {:put, "/applications/#{DiscordBot.id()}/commands"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_application_commands(guild_id) do
    {:get, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands"}
    |> request()
  end

  @doc since: "0.6.0"
  def create_guild_application_command(guild_id, command_id) do
    {:create, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands/#{command_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_application_command(guild_id, command_id) do
    {:get, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands/#{command_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_guild_application_command(guild_id, command_id) do
    {:patch, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands/#{command_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_guild_application_command(guild_id, command_id) do
    {:delete, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands/#{command_id}"}
    |> request()
  end

  @doc """
  Overwrite the existing guild application commands on the specified guild.

  This action will:
  - Create any command that was provided and did not already exist
  - Update any command that was provided and already existed if its configuration changed
  - Delete any command that was not provided but existed on Discord's end

  ## Parameters
  - `application_id`: Application ID for which to overwrite the commands.
    If not given, this will be fetched from `Me`.
  - `guild_id`: Guild on which to overwrite the commands.
  - `commands`: List of command configurations, see the linked API documentation for reference.

  ## Return value
  Updated list of guild application commands. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#bulk-overwrite-guild-application-commands
  """
  def bulk_overwrite_guild_application_commands(guild_id) do
    {:put, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_guild_application_command_permissions(guild_id) do
    {:get, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands/permissions"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_application_command_permissions(guild_id, command_id) do
    {:get, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands/#{command_id}/permissions"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_application_command_permissions(guild_id, command_id) do
    {:put, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands/#{command_id}/permissions"}
    |> request()
  end

  @doc since: "0.6.0"
  def batch_modify_application_command_permissions(guild_id) do
    {:put, "/applications/#{DiscordBot.id()}/guilds/#{guild_id}/commands/permissions"}
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
    {:get, "/webhooks/#{DiscordBot.id()}/#{interaction_token}/messages/@original"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_original_interaction_response(interaction_token) do
    {:patch, "/webhooks/#{DiscordBot.id()}/#{interaction_token}/messages/@original"}
    |> request()
  end

  @doc since: "0.6.0"
  def delete_original_interaction_response(interaction_token) do
    {:delete, "/webhooks/#{DiscordBot.id()}/#{interaction_token}/messages/@original"}
    |> request()
  end

  @doc """
  Create a followup message for an interaction.

  Delegates to ``execute_webhook/3``, see the function for more details.
  """

  def create_followup_message(interaction_token) do
    {:post, "/webhooks/#{DiscordBot.id()}/#{interaction_token}"}
    |> request()
  end

  @doc since: "0.6.0"
  def get_followup_message(interaction_token, message_id) do
    {:get, "/webhooks/#{DiscordBot.id()}/#{interaction_token}/messsages/#{message_id}"}
    |> request()
  end

  @doc since: "0.6.0"
  def modify_followup_message(interaction_token, message_id) do
    {:patch, "/webhooks/#{DiscordBot.id()}/#{interaction_token}/messsages/#{message_id}"}
    |> request()
  end

  @doc """
  Delete a followup message for an interaction.

  ## Parameters
  - `application_id`: Application ID for which to create the command.
    If not given, this will be fetched from `Me`.
  - `token`: Interaction token.
  - `message_id`: Followup message ID.
  """
  def delete_followup_message(interaction_token, message_id) do
    {:delete, "/webhooks/#{DiscordBot.id()}/#{interaction_token}/messsages/#{message_id}"}
    |> request()
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

  @doc """
  Gets a gateway URL.

  ## Examples

        iex> Remedy.API.get_gateway()
        {:ok, "wss://gateway.discord.gg"}


  """
  @spec get_gateway :: {:error, any} | {:ok, any}

  @doc since: "0.6.0"
  @unsafe {:get_gateway, []}
  def get_gateway do
    {:get, "/gateway"}
    |> request()
    |> parse_get_gateway()
  end

  defp parse_get_gateway({:error, _reason} = error), do: error
  defp parse_get_gateway({:ok, %{url: url}}), do: {:ok, url}

  @doc """
  Gets a Gateway Bot Object.
  """

  @doc since: "0.6.0"
  @unsafe {:get_gateway_bot, []}
  def get_gateway_bot do
    {:get, "/gateway/bot"}
    |> request()
    |> parse_get_gateway_bot()
  end

  defp parse_get_gateway_bot({:error, _reason} = error), do: error
  defp parse_get_gateway_bot({:ok, gateway}), do: {:ok, gateway}

  defp request({_, _} = rest_request),
    do: request(rest_request, %{}, nil, nil)

  defp request({_, _} = rest_request, params) when is_list(params),
    do: request(rest_request, %{}, params, nil)

  defp request({_, _} = rest_request, %{} = body),
    do: request(rest_request, body, nil, nil)

  defp request({_, _} = rest_request, body, nil),
    do: request(rest_request, body)

  defp request({_, _} = rest_request, body, reason),
    do: request(rest_request, body, nil, reason)

  import Remedy.API.RestRequest

  defp request(rest_request, body, params, reason_header) do
    rest_request
    |> base_request()
    |> add_request_query_params(params)
    |> add_request_audit_log_headers(reason_header)
    |> add_request_body(body)
    |> handle_request()
  end

  defp handle_request(request), do: request |> Rest.request()

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise(Remedy.APIError)

  defp clean_map(defaults, opts) do
    opts
    |> Enum.reject(fn {_, v} -> v == nil end)
    |> Enum.into(flatten(defaults))
    |> Enum.filter(fn {k, _} -> k in Map.keys(defaults) end)
    |> Enum.into(%{})
    |> flatten()
  end

  ## Destroy all structs and ensure nested map
  defp flatten(map), do: :maps.map(&do_flatten/2, map) |> Map.from_struct()
  defp do_flatten(_key, value), do: enm(value)
  defp enm(list) when is_list(list), do: Enum.map(list, &enm/1)
  defp enm(%{__struct__: _} = strct), do: :maps.map(&do_flatten/2, Map.from_struct(strct))
  defp enm(data), do: data
end
