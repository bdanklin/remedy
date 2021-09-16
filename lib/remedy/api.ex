defmodule Remedy.Api do
  @moduledoc """
  Hello
  """

  use Bitwise
  import Remedy.ModelHelpers

  alias Remedy.{Bot, Endpoints}
  alias Remedy.Api.{Endpoints, Ratelimiter}

  import Sunbake.Snowflake,
    only: [is_snowflake: 1],
    warn: false

  alias Remedy.Schema.{
    AuditLog,
    AuditLogEntry,
    Channel,
    Embed,
    Emoji,
    Guild,
    Interaction,
    Member,
    Message,
    Role,
    User,
    Webhook
  }

  @type error :: {:error, Remedy.ApiError.t() | HTTPoison.Error.t()}

  @type limit :: integer | :infinity

  @type locator ::
          {:before, integer}
          | {:after, integer}
          | {:around, integer}
          | {}

  @type status :: :dnd | :idle | :online | :invisible

  @type emoji :: Emoji.t() | Emoji.api_name()

  @type options :: keyword | map

  # TODO: Not Ideal level of abstraction for the user. needing the pid is pretty aids.
  # @spec update_shard_status(pid, status, String.t(), integer, String.t() | nil) :: :ok
  # def update_shard_status(pid, status, game, type \\ 0, stream \\ nil) do
  #   Session.update_status(pid, to_string(status), game, stream, type)
  #   :ok
  # end

  # @spec update_status(status, String.t(), integer, String.t() | nil) :: :ok
  # def update_status(status, game, type \\ 0, stream \\ nil) do
  #   Supervisor.update_status(to_string(status), game, stream, type)
  #   :ok
  # end

  # @doc """
  # Joins, moves, or disconnects the bot from a voice channel.

  # The correct shard to send the update to will be inferred from the
  # `guild_id`. If a corresponding `guild_id` is not found a cache error will be
  # raised.

  # To disconnect from a channel, `channel_id` should be set to `nil`.
  # """
  # @spec update_voice_state(Guild.id(), Channel.id() | nil, boolean, boolean) :: no_return | :ok
  # def update_voice_state(guild_id, channel_id, self_mute \\ false, self_deaf \\ false) do
  #   Supervisor.update_voice_state(guild_id, channel_id, self_mute, self_deaf)
  # end

  @doc ~S"""
  Posts a message to a guild text or DM channel.

  This endpoint requires the `VIEW_CHANNEL` and `SEND_MESSAGES` permissions. It
  may situationally need the `SEND_MESSAGES_TTS` permission. It fires the
  `t:Remedy.Consumer.message_create/0` event.

  If `options` is a string, `options` will be used as the message's content.

  If successful, returns `{:ok, message}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:content` (string) - the message contents (up to 2000 characters)
    * `:nonce` (`t:Sunbake.Snowflake.t/0`) - a nonce that can be used for
    optimistic message sending
    * `:tts` (boolean) - true if this is a TTS message
    * `:file` (`t:Path.t/0` | map) - the path of the file being sent, or a map with the following keys
    if sending a binary from memory
      * `:name` (string) - the name of the file
      * `:body` (string) - binary you wish to send
    * `:embed` (`t:Remedy.Struct.Embed.t/0`) - embedded rich content
    * `:allowed_mentions` - See "Allowed mentions" below
    * `:message_reference` (`map`) - See "Message references" below

    At least one of the following is required: `:content`, `:file`, `:embed`.

  ## Allowed mentions

  With this option you can control when content from a message should trigger a ping.
  Consider using this option when you are going to display user_generated content.

  ### Allowed values
    * `:all` (default) - Ping everything as usual
    * `:none` - Nobody will be pinged
    * `:everyone` - Allows to ping @here and @everone
    * `:users` - Allows to ping users
    * `:roles` - Allows to ping roles
    * `{:users, list}` - Allows to ping list of users. Can contain up to 100 ids of users.
    * `{:roles, list}` - Allows to ping list of roles. Can contain up to 100 ids of roles.
    * list - a list containing the values above.

  ### Message reference

  You can create a reply to another message on guilds using this option, given
  that you have the ``VIEW_MESSAGE_HISTORY`` permission. To do so, include the
  ``message_reference`` field in your call. The complete structure
  documentation can be found [on the Discord Developer
  Portal](https://discord.com/developers/docs/resources/channel#message-object-message-reference-structure),
  but simply passing ``message_id`` will suffice:

  ```elixir
  def my_command(msg) do
    # Reply to the author - ``msg`` is a ``Remedy.Struct.Message``
    Remedy.Api.create_message(
      msg.channel_id,
      content: "Hello",
      message_reference: %{message_id: msg.id}
    )
  end
  ```

  Passing a list will merge the settings provided

  ## Examples

  ```Elixir
  Remedy.Api.create_message(43189401384091, content: "hello world!")

  Remedy.Api.create_message(43189401384091, "hello world!")

  import Remedy.Struct.Embed
  embed =
    %Remedy.Struct.Embed{}
    |> put_title("embed")
    |> put_description("new desc")
  Remedy.Api.create_message(43189401384091, embed: embed)

  Remedy.Api.create_message(43189401384091, file: "/path/to/file.txt")

  Remedy.Api.create_message(43189401384091, content: "hello world!", embed: embed, file: "/path/to/file.txt")

  Remedy.Api.create_message(43189401384091, content: "Hello @everyone", allowed_mentions: :none)
  ```
  """

  @spec create_message(Channel.id() | Message.t(), options | String.t()) ::
          error | {:ok, Message.t()}
  def create_message(channel_id, options)

  def create_message(%Message{} = message, options),
    do: create_message(message.channel_id, options)

  def create_message(channel_id, options) when is_list(options),
    do: create_message(channel_id, Map.new(options))

  def create_message(channel_id, %{} = options) when is_snowflake(channel_id) do
    options = prepare_allowed_mentions(options)

    case options do
      %{file: _} -> create_message_with_multipart(channel_id, options)
      _ -> create_message_with_json(channel_id, options)
    end
  end

  def create_message(channel_id, content) when is_snowflake(channel_id) and is_binary(content),
    do: create_message_with_json(channel_id, %{content: content})

  defp create_message_with_multipart(channel_id, %{file: file} = options) do
    payload_json =
      options
      |> Map.delete(:file)
      |> Poison.encode!()

    request = %{
      method: :post,
      route: Endpoints.channel_messages(channel_id),
      body: {:multipart, [create_multipart(file), {"payload_json", payload_json}]},
      options: [],
      headers: [
        {"content-type", "multipart/form-data"}
      ]
    }

    GenServer.call(Ratelimiter, {:queue, request, nil}, :infinity)
    |> handle_request_with_decode({:struct, Message})
  end

  defp create_multipart(path) when is_binary(path) do
    {:file, path}
  end

  defp create_multipart(%{name: name, body: body}) do
    {"file", body, {"form-data", [{"name", "file"}, {"filename", name}]},
     [{"Content-Type", "multipart/form-data"}]}
  end

  defp create_message_with_json(channel_id, options) do
    request(:post, Endpoints.channel_messages(channel_id), options)
    |> handle_request_with_decode({:struct, Message})
  end

  @doc ~S"""
  Same as `create_message/2`, but raises `Remedy.ApiError` in case of failure.
  """

  @spec create_message!(Channel.id() | Message.t(), options | String.t()) ::
          no_return | Message.t()
  def create_message!(channel_id, options) do
    create_message(channel_id, options)
    |> bangify
  end

  @doc ~S"""
  Edits a previously sent message in a channel.

  This endpoint requires the `VIEW_CHANNEL` permission. It fires the
  `t:Remedy.Consumer.message_update/0` event.

  If `options` is a string, `options` will be used as the message's content.

  If successful, returns `{:ok, message}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:content` (string) - the message contents (up to 2000 characters)
    * `:embed` (`t:Remedy.Struct.Embed.t/0`) - embedded rich content

  ## Examples

  ```Elixir
  Remedy.Api.edit_message(43189401384091, 1894013840914098, content: "hello world!")

  Remedy.Api.edit_message(43189401384091, 1894013840914098, "hello world!")

  import Remedy.Struct.Embed
  embed =
    %Remedy.Struct.Embed{}
    |> put_title("embed")
    |> put_description("new desc")
  Remedy.Api.edit_message(43189401384091, 1894013840914098, embed: embed)

  Remedy.Api.edit_message(43189401384091, 1894013840914098, content: "hello world!", embed: embed)
  ```
  """

  @spec edit_message(Channel.id(), Message.id(), options | String.t()) ::
          error | {:ok, Message.t()}
  def edit_message(channel_id, message_id, options)

  def edit_message(channel_id, message_id, options) when is_list(options),
    do: edit_message(channel_id, message_id, Map.new(options))

  def edit_message(channel_id, message_id, %{} = options)
      when is_snowflake(channel_id) and is_snowflake(message_id) do
    request(:patch, Endpoints.channel_message(channel_id, message_id), options)
    |> handle_request_with_decode({:struct, Message})
  end

  def edit_message(channel_id, message_id, content)
      when is_snowflake(channel_id) and is_snowflake(message_id) and is_binary(content) do
    request(:patch, Endpoints.channel_message(channel_id, message_id), %{content: content})
    |> handle_request_with_decode({:struct, Message})
  end

  @doc ~S"""
  Same as `edit_message/3`, but raises `Remedy.ApiError` in case of failure.
  """

  @spec edit_message!(Channel.id(), Message.id(), options) :: no_return | Message.t()
  def edit_message!(channel_id, message_id, options) do
    edit_message(channel_id, message_id, options)
    |> bangify
  end

  @doc ~S"""
  Same as `edit_message/3`, but takes a `Remedy.Struct.Message` instead of a
  `channel_id` and `message_id`.
  """

  @spec edit_message(Message.t(), options) :: error | {:ok, Message.t()}
  def edit_message(%Message{id: id, channel_id: c_id}, options) do
    edit_message(c_id, id, options)
  end

  @doc ~S"""
  Same as `delete_message/2`, but takes a `Remedy.Struct.Message` instead of a
  `channel_id` and `message_id`.
  """

  @spec delete_message(Message.t()) :: error | {:ok}
  def delete_message(%Message{id: id, channel_id: c_id}) do
    delete_message(c_id, id)
  end

  @doc ~S"""
  Deletes a message.

  This endpoint requires the 'VIEW_CHANNEL' and 'MANAGE_MESSAGES' permission. It
  fires the `MESSAGE_DELETE` event.

  If successful, returns `{:ok}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.delete_message(43189401384091, 43189401384091)
  ```
  """

  @spec delete_message(Channel.id(), Message.id()) :: error | {:ok}
  def delete_message(channel_id, message_id)
      when is_snowflake(channel_id) and is_snowflake(message_id) do
    request(:delete, Endpoints.channel_message(channel_id, message_id))
  end

  @doc ~S"""
  Creates a reaction for a message.

  This endpoint requires the `VIEW_CHANNEL` and `READ_MESSAGE_HISTORY`
  permissions. Additionally, if nobody else has reacted to the message with
  the `emoji`, this endpoint requires the `ADD_REACTIONS` permission. It
  fires a `t:Remedy.Consumer.message_reaction_add/0` event.

  If successful, returns `{:ok}`. Otherwise, returns `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  # Using a Remedy.Struct.Emoji.
  emoji = %Remedy.Struct.Emoji{id: 43819043108, name: "foxbot"}
  Remedy.Api.create_reaction(123123123123, 321321321321, emoji)

  # Using a base 16 emoji string.
  Remedy.Api.create_reaction(123123123123, 321321321321, "\xF0\x9F\x98\x81")

  ```

  For other emoji string examples, see `t:Remedy.Struct.Emoji.api_name/0`.
  """

  @spec create_reaction(Channel.id(), Message.id(), emoji) :: error | {:ok}
  def create_reaction(channel_id, message_id, emoji)

  def create_reaction(channel_id, message_id, %Emoji{} = emoji),
    do: create_reaction(channel_id, message_id, Emoji.api_name(emoji))

  def create_reaction(channel_id, message_id, emoji_api_name) do
    request(:put, Endpoints.channel_reaction_me(channel_id, message_id, emoji_api_name))
  end

  @doc ~S"""
  Deletes a reaction the current user has made for the message.

  This endpoint requires the `VIEW_CHANNEL` and `READ_MESSAGE_HISTORY`
  permissions. It fires a `t:Remedy.Consumer.message_reaction_remove/0` event.

  If successful, returns `{:ok}`. Otherwise, returns `t:Remedy.Api.error/0`.

  See `create_reaction/3` for similar examples.
  """

  @spec delete_own_reaction(Channel.id(), Message.id(), emoji) :: error | {:ok}
  def delete_own_reaction(channel_id, message_id, emoji)

  def delete_own_reaction(channel_id, message_id, %Emoji{} = emoji),
    do: delete_own_reaction(channel_id, message_id, Emoji.api_name(emoji))

  def delete_own_reaction(channel_id, message_id, emoji_api_name) do
    request(:delete, Endpoints.channel_reaction_me(channel_id, message_id, emoji_api_name))
  end

  @doc ~S"""
  Deletes another user's reaction from a message.

  This endpoint requires the `VIEW_CHANNEL`, `READ_MESSAGE_HISTORY`, and
  `MANAGE_MESSAGES` permissions. It fires a `t:Remedy.Consumer.message_reaction_remove/0` event.

  If successful, returns `{:ok}`. Otherwise, returns `t:Remedy.Api.error/0`.

  See `create_reaction/3` for similar examples.
  """

  @spec delete_user_reaction(Channel.id(), Message.id(), emoji, User.id()) :: error | {:ok}
  def delete_user_reaction(channel_id, message_id, emoji, user_id)

  def delete_user_reaction(channel_id, message_id, %Emoji{} = emoji, user_id),
    do: delete_user_reaction(channel_id, message_id, Emoji.api_name(emoji), user_id)

  def delete_user_reaction(channel_id, message_id, emoji_api_name, user_id) do
    request(:delete, Endpoints.channel_reaction(channel_id, message_id, emoji_api_name, user_id))
  end

  @doc ~S"""
  Deletes all reactions of a given emoji from a message.

  This endpoint requires the `MANAGE_MESSAGES` permissions. It fires a `t:Remedy.Consumer.message_reaction_remove_emoji/0` event.

  If successful, returns `{:ok}`. Otherwise, returns `t:Remedy.Api.error/0`.

  See `create_reaction/3` for similar examples.
  """

  @spec delete_reaction(Channel.id(), Message.id(), emoji) :: error | {:ok}
  def delete_reaction(channel_id, message_id, emoji)

  def delete_reaction(channel_id, message_id, %Emoji{} = emoji),
    do: delete_reaction(channel_id, message_id, Emoji.api_name(emoji))

  def delete_reaction(channel_id, message_id, emoji_api_name) do
    request(
      :delete,
      Endpoints.channel_reactions_delete_emoji(channel_id, message_id, emoji_api_name)
    )
  end

  @doc ~S"""
  Gets all users who reacted with an emoji.

  This endpoint requires the `VIEW_CHANNEL` and `READ_MESSAGE_HISTORY` permissions.

  If successful, returns `{:ok, users}`. Otherwise, returns `t:Remedy.Api.error/0`.

  See `create_reaction/3` for similar examples.
  """

  @spec get_reactions(Channel.id(), Message.id(), emoji) :: error | {:ok, [User.t()]}
  def get_reactions(channel_id, message_id, emoji)

  def get_reactions(channel_id, message_id, %Emoji{} = emoji),
    do: get_reactions(channel_id, message_id, Emoji.api_name(emoji))

  def get_reactions(channel_id, message_id, emoji_api_name) do
    request(:get, Endpoints.channel_reactions_get(channel_id, message_id, emoji_api_name))
    |> handle_request_with_decode({:list, {:struct, User}})
  end

  @doc ~S"""
  Deletes all reactions from a message.

  This endpoint requires the `VIEW_CHANNEL`, `READ_MESSAGE_HISTORY`, and
  `MANAGE_MESSAGES` permissions. It fires a `t:Remedy.Consumer.message_reaction_remove_all/0` event.

  If successful, returns `{:ok}`. Otherwise, return `t:Remedy.Api.error/0`.
  """

  @spec delete_all_reactions(Channel.id(), Message.id()) :: error | {:ok}
  def delete_all_reactions(channel_id, message_id) do
    request(:delete, Endpoints.channel_reactions_delete(channel_id, message_id))
  end

  @doc ~S"""
  Gets a channel.

  If successful, returns `{:ok, channel}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_channel(381889573426429952)
  {:ok, %Remedy.Struct.Channel{id: 381889573426429952}}
  ```
  """

  @spec get_channel(Channel.id()) :: error | {:ok, Channel.t()}
  def get_channel(channel_id) when is_snowflake(channel_id) do
    request(:get, Endpoints.channel(channel_id))
    |> handle_request_with_decode({:struct, Channel})
  end

  @doc ~S"""
  Modifies a channel's settings.

  An optional `reason` can be given for the guild audit log.

  If a `t:Remedy.Struct.Channel.guild_channel/0` is being modified, this
  endpoint requires the `MANAGE_CHANNEL` permission. It fires a
  `t:Remedy.Consumer.channel_update/0` event. If a
  `t:Remedy.Struct.Channel.channel_category/0` is being modified, then this
  endpoint fires multiple `t:Remedy.Consumer.channel_update/0` events.

  If successful, returns `{:ok, channel}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:name` (string) - 2-100 character channel name
    * `:position` (integer) - the position of the channel in the left-hand listing
    * `:topic` (string) (`t:Remedy.Struct.Channel.text_channel/0` only) -
    0-1024 character channel topic
    * `:nsfw` (boolean) (`t:Remedy.Struct.Channel.text_channel/0` only) -
    if the channel is nsfw
    * `:bitrate` (integer) (`t:Remedy.Struct.Channel.voice_channel/0` only) -
    the bitrate (in bits) of the voice channel; 8000 to 96000 (128000 for VIP servers)
    * `:user_limit` (integer) (`t:Remedy.Struct.Channel.voice_channel/0` only) -
    the user limit of the voice channel; 0 refers to no limit, 1 to 99 refers to a user limit
    * `:permission_overwrites` (list of `t:Remedy.Struct.Overwrite.t/0` or equivalent map) -
    channel or category-specific permissions
    * `:parent_id` (`t:Remedy.Struct.Channel.id/0`) (`t:Remedy.Struct.Channel.guild_channel/0` only) -
    id of the new parent category for a channel

  ## Examples

  ```Elixir
  Remedy.Api.modify_channel(41771983423143933, name: "elixir-remedy", topic: "remedy discussion")
  {:ok, %Remedy.Struct.Channel{id: 41771983423143933, name: "elixir-remedy", topic: "remedy discussion"}}

  Remedy.Api.modify_channel(41771983423143933)
  {:ok, %Remedy.Struct.Channel{id: 41771983423143933}}
  ```
  """

  @spec modify_channel(Channel.id(), options, AuditLogEntry.reason()) ::
          error | {:ok, Channel.t()}
  def modify_channel(channel_id, options, reason \\ nil)

  def modify_channel(channel_id, options, reason) when is_list(options),
    do: modify_channel(channel_id, Map.new(options), reason)

  def modify_channel(channel_id, %{} = options, reason) when is_snowflake(channel_id) do
    %{
      method: :patch,
      route: Endpoints.channel(channel_id),
      body: options,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request
    |> handle_request_with_decode({:struct, Channel})
  end

  @doc ~S"""
  Deletes a channel.

  An optional `reason` can be provided for the guild audit log.

  If deleting a `t:Remedy.Struct.Channel.guild_channel/0`, this endpoint requires
  the `MANAGE_CHANNELS` permission. It fires a
  `t:Remedy.Consumer.channel_delete/0`. If a `t:Remedy.Struct.Channel.channel_category/0`
  is deleted, then a `t:Remedy.Consumer.channel_update/0` event will fire
  for each channel under the category.

  If successful, returns `{:ok, channel}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.delete_channel(421533712753360896)
  {:ok, %Remedy.Struct.Channel{id: 421533712753360896}}
  ```
  """

  @spec delete_channel(Channel.id(), AuditLogEntry.reason()) :: error | {:ok, Channel.t()}
  def delete_channel(channel_id, reason \\ nil) when is_snowflake(channel_id) do
    %{
      method: :delete,
      route: Endpoints.channel(channel_id),
      body: "",
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode({:struct, Channel})
  end

  @doc ~S"""
  Retrieves a channel's messages around a `locator` up to a `limit`.

  This endpoint requires the 'VIEW_CHANNEL' permission. If the current user
  is missing the 'READ_MESSAGE_HISTORY' permission, then this function will
  return no messages.

  If successful, returns `{:ok, messages}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_channel_messages(43189401384091, 5, {:before, 130230401384})
  ```
  """

  @spec get_channel_messages(Channel.id(), limit, locator) :: error | {:ok, [Message.t()]}
  def get_channel_messages(channel_id, limit, locator \\ {}) when is_snowflake(channel_id) do
    get_messages_sync(channel_id, limit, [], locator)
  end

  defp get_messages_sync(channel_id, limit, messages, locator) when limit <= 100 do
    case get_channel_messages_call(channel_id, limit, locator) do
      {:ok, new_messages} -> {:ok, messages ++ new_messages}
      other -> other
    end
  end

  defp get_messages_sync(channel_id, limit, messages, locator) do
    case get_channel_messages_call(channel_id, 100, locator) do
      {:error, message} ->
        {:error, message}

      {:ok, []} ->
        {:ok, messages}

      {:ok, new_messages} ->
        new_limit = get_new_limit(limit, length(new_messages))
        new_locator = get_new_locator(locator, List.last(new_messages))
        get_messages_sync(channel_id, new_limit, messages ++ new_messages, new_locator)
    end
  end

  defp get_new_locator({}, last_message), do: {:before, last_message.id}
  defp get_new_locator(locator, last_message), do: put_elem(locator, 1, last_message.id)

  defp get_new_limit(:infinity, _new_message_count), do: :infinity
  defp get_new_limit(limit, message_count), do: limit - message_count

  # We're decoding the response at each call to catch any errors
  @doc false
  def get_channel_messages_call(channel_id, limit, locator) do
    qs_params =
      case locator do
        {} -> [{:limit, limit}]
        non_empty_locator -> [{:limit, limit}, non_empty_locator]
      end

    request(:get, Endpoints.channel_messages(channel_id), "", params: qs_params)
    |> handle_request_with_decode({:list, {:struct, Message}})
  end

  @doc ~S"""
  Retrieves a message from a channel.

  This endpoint requires the 'VIEW_CHANNEL' and 'READ_MESSAGE_HISTORY' permissions.

  If successful, returns `{:ok, message}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_channel_message(43189401384091, 198238475613443)
  ```
  """

  @spec get_channel_message(Channel.id(), Message.id()) :: error | {:ok, Message.t()}
  def get_channel_message(channel_id, message_id)
      when is_snowflake(channel_id) and is_snowflake(message_id) do
    request(:get, Endpoints.channel_message(channel_id, message_id))
    |> handle_request_with_decode({:struct, Message})
  end

  @doc """
  Deletes multiple messages from a channel.

  `messages` is a list of `Remedy.Struct.Message.id` that you wish to delete.
  When given more than 100 messages, this function will chunk the given message
  list into blocks of 100 and send them off to the API. It will stop deleting
  on the first error that occurs. Keep in mind that deleting thousands of
  messages will take a pretty long time and it may be proper to just delete
  the channel you want to bulk delete in and recreate it.

  This method can only delete messages sent within the last two weeks.
  `Filter` is an optional parameter that specifies whether messages sent over
  two weeks ago should be filtered out; defaults to `true`.
  """

  @spec bulk_delete_messages(integer, [Remedy.Struct.Message.id()], boolean) :: error | {:ok}
  def bulk_delete_messages(channel_id, messages, filter \\ true)

  def bulk_delete_messages(channel_id, messages, false),
    do: send_chunked_delete(messages, channel_id)

  def bulk_delete_messages(channel_id, messages, true) do
    alias Sunbake.Snowflake

    snowflake_two_weeks_ago =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.-(60 * 60 * 24 * 14)
      |> DateTime.from_unix!()
      |> Snowflake.from_datetime!()

    messages
    |> Stream.filter(&(&1 > snowflake_two_weeks_ago))
    |> send_chunked_delete(channel_id)
  end

  @spec send_chunked_delete(
          [Remedy.Struct.Message.id()] | %Stream{},
          Sunbake.Snowflake.t()
        ) :: error | {:ok}
  defp send_chunked_delete(messages, channel_id) do
    messages
    |> Stream.chunk_every(100)
    |> Stream.map(fn message_chunk ->
      request(
        :post,
        Endpoints.channel_bulk_delete(channel_id),
        %{messages: message_chunk}
      )
    end)
    |> Enum.find({:ok}, &match?({:error, _}, &1))
  end

  @doc """
  Edit the permission overwrites for a user or role.

  Role or user to overwrite is specified by `overwrite_id`.

  `permission_info` is a map with the following keys:
   * `type` - Required; `member` if editing a user, `role` if editing a role.
   * `allow` - Bitwise value of allowed permissions.
   * `deny` - Bitwise value of denied permissions.
   * `type` - `member` if editing a user, `role` if editing a role.

  An optional `reason` can be provided for the audit log.

   `allow` and `deny` are defaulted to `0`, meaning that even if you don't
   specify them, they will override their respective former values in an
   existing overwrite.
  """

  @spec edit_channel_permissions(
          integer,
          integer,
          %{
            required(:type) => String.t(),
            optional(:allow) => integer,
            optional(:deny) => integer
          },
          AuditLogEntry.reason()
        ) :: error | {:ok}
  def edit_channel_permissions(channel_id, overwrite_id, permission_info, reason \\ nil) do
    request(%{
      method: :put,
      route: Endpoints.channel_permission(channel_id, overwrite_id),
      body: permission_info,
      options: [],
      headers: maybe_add_reason(reason)
    })
  end

  @doc """
  Delete a channel permission for a user or role.

  Role or user overwrite to delete is specified by `channel_id` and `overwrite_id`.
  An optional `reason` can be given for the audit log.
  """

  @spec delete_channel_permissions(integer, integer, AuditLogEntry.reason()) :: error | {:ok}
  def delete_channel_permissions(channel_id, overwrite_id, reason \\ nil) do
    request(%{
      method: :delete,
      route: Endpoints.channel_permission(channel_id, overwrite_id),
      body: "",
      options: [],
      headers: maybe_add_reason(reason)
    })
  end

  @doc ~S"""
  Gets a list of invites for a channel.

  This endpoint requires the 'VIEW_CHANNEL' and 'MANAGE_CHANNELS' permissions.

  If successful, returns `{:ok, invite}`. Otherwise, returns a
  `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_channel_invites(43189401384091)
  {:ok, [%Remedy.Struct.Invite{} | _]}
  ```
  """

  @spec get_channel_invites(Channel.id()) :: error | {:ok, [Invite.detailed_invite()]}
  def get_channel_invites(channel_id) when is_snowflake(channel_id) do
    request(:get, Endpoints.channel_invites(channel_id))
    |> handle_request_with_decode({:list, {:struct, Invite}})
  end

  @doc ~S"""
  Creates an invite for a guild channel.

  An optional `reason` can be provided for the audit log.

  This endpoint requires the `CREATE_INSTANT_INVITE` permission.

  If successful, returns `{:ok, invite}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:max_age` (integer) - duration of invite in seconds before expiry, or 0 for never.
      (default: `86400`)
    * `:max_uses` (integer) - max number of uses or 0 for unlimited.
      (default: `0`)
    * `:temporary` (boolean) - Whether the invite should grant temporary
      membership. (default: `false`)
    * `:unique` (boolean) - used when creating unique one time use invites.
      (default: `false`)

  ## Examples

  ```Elixir
  Remedy.Api.create_channel_invite(41771983423143933)
  {:ok, Remedy.Struct.Invite{}}

  Remedy.Api.create_channel_invite(41771983423143933, max_uses: 20)
  {:ok, %Remedy.Struct.Invite{}}
  ```
  """

  @spec create_channel_invite(Channel.id(), options, AuditLogEntry.reason()) ::
          error | {:ok, Invite.detailed_invite()}
  def create_channel_invite(channel_id, options \\ [], reason \\ nil)

  def create_channel_invite(channel_id, options, reason) when is_list(options),
    do: create_channel_invite(channel_id, Map.new(options), reason)

  def create_channel_invite(channel_id, options, reason)
      when is_snowflake(channel_id) and is_map(options) do
    %{
      method: :post,
      route: Endpoints.channel_invites(channel_id),
      body: options,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode({:struct, Invite})
  end

  @doc ~S"""
  Same as `create_channel_invite/2`, but raises `Remedy.ApiError` in case of failure.
  """

  @spec create_channel_invite!(Channel.id(), options, AuditLogEntry.reason()) ::
          no_return | Invite.detailed_invite()
  def create_channel_invite!(channel_id, options \\ [], reason \\ nil) do
    create_channel_invite(channel_id, options, reason)
    |> bangify
  end

  @doc """
  Triggers the typing indicator.

  Triggers the typing indicator in the channel specified by `channel_id`.
  The typing indicator lasts for about 8 seconds and then automatically stops.

  Returns `{:ok}` if successful. `error` otherwise.
  """

  @spec start_typing(integer) :: error | {:ok}
  def start_typing(channel_id) do
    request(:post, Endpoints.channel_typing(channel_id))
  end

  @doc ~S"""
  Retrieves all pinned messages from a channel.

  This endpoint requires the 'VIEW_CHANNEL' and 'READ_MESSAGE_HISTORY' permissions.

  If successful, returns `{:ok, messages}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_pinned_messages(43189401384091)
  ```
  """

  @spec get_pinned_messages(Channel.id()) :: error | {:ok, [Message.t()]}
  def get_pinned_messages(channel_id) when is_snowflake(channel_id) do
    request(:get, Endpoints.channel_pins(channel_id))
    |> handle_request_with_decode({:list, {:struct, Message}})
  end

  @doc ~S"""
  Pins a message in a channel.

  This endpoint requires the 'VIEW_CHANNEL', 'READ_MESSAGE_HISTORY', and
  'MANAGE_MESSAGES' permissions. It fires the
  `t:Remedy.Consumer.message_update/0` and
  `t:Remedy.Consumer.channel_pins_update/0` events.

  If successful, returns `{:ok}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.add_pinned_channel_message(43189401384091, 18743893102394)
  ```
  """

  @spec add_pinned_channel_message(Channel.id(), Message.id()) :: error | {:ok}
  def add_pinned_channel_message(channel_id, message_id)
      when is_snowflake(channel_id) and is_snowflake(message_id) do
    request(:put, Endpoints.channel_pin(channel_id, message_id))
  end

  @doc """
  Unpins a message in a channel.

  This endpoint requires the 'VIEW_CHANNEL', 'READ_MESSAGE_HISTORY', and
  'MANAGE_MESSAGES' permissions. It fires the
  `t:Remedy.Consumer.message_update/0` and
  `t:Remedy.Consumer.channel_pins_update/0` events.

  Returns `{:ok}` if successful. `error` otherwise.
  """

  @spec delete_pinned_channel_message(Channel.id(), Message.id()) :: error | {:ok}
  def delete_pinned_channel_message(channel_id, message_id)
      when is_snowflake(channel_id) and is_snowflake(message_id) do
    request(:delete, Endpoints.channel_pin(channel_id, message_id))
  end

  @doc ~S"""
  Gets a list of emojis for a given guild.

  This endpoint requires the `MANAGE_EMOJIS` permission.

  If successful, returns `{:ok, emojis}`. Otherwise, returns `t:Remedy.Api.error/0`.
  """

  @spec list_guild_emojis(Guild.id()) :: error | {:ok, [Emoji.t()]}
  def list_guild_emojis(guild_id) do
    request(:get, Endpoints.guild_emojis(guild_id))
    |> handle_request_with_decode({:list, {:struct, Emoji}})
  end

  @doc ~S"""
  Gets an emoji for the given guild and emoji ids.

  This endpoint requires the `MANAGE_EMOJIS` permission.

  If successful, returns `{:ok, emoji}`. Otherwise, returns `t:Remedy.Api.error/0`.
  """

  @spec get_guild_emoji(Guild.id(), Emoji.id()) :: error | {:ok, Emoji.t()}
  def get_guild_emoji(guild_id, emoji_id) do
    request(:get, Endpoints.guild_emoji(guild_id, emoji_id))
    |> handle_request_with_decode({:struct, Emoji})
  end

  @doc ~S"""
  Creates a new emoji for the given guild.

  This endpoint requires the `MANAGE_EMOJIS` permission. It fires a
  `t:Remedy.Consumer.guild_emojis_update/0` event.

  An optional `reason` can be provided for the audit log.

  If successful, returns `{:ok, emoji}`. Otherwise, returns `t:Remedy.Api.error/0`.

  ## Options

    * `:name` (string) - name of the emoji
    * `:image` (base64 data URI) - the 128x128 emoji image. Maximum size of 256kb
    * `:roles` (list of `t:Sunbake.Snowflake.t/0`) - roles for which this emoji will be whitelisted
    (default: [])

  `:name` and `:image` are always required.

  ## Examples

  ```Elixir
  image = "data:image/png;base64,YXl5IGJieSB1IGx1a2luIDQgc3VtIGZ1az8="

  Remedy.Api.create_guild_emoji(43189401384091, name: "remedy", image: image, roles: [])
  ```
  """

  @spec create_guild_emoji(Guild.id(), options, AuditLogEntry.reason()) ::
          error | {:ok, Emoji.t()}
  def create_guild_emoji(guild_id, options, reason \\ nil)

  def create_guild_emoji(guild_id, options, reason) when is_list(options),
    do: create_guild_emoji(guild_id, Map.new(options), reason)

  def create_guild_emoji(guild_id, %{} = options, reason) do
    %{
      method: :post,
      route: Endpoints.guild_emojis(guild_id),
      body: options,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode({:struct, Emoji})
  end

  @doc ~S"""
  Modify the given emoji.

  This endpoint requires the `MANAGE_EMOJIS` permission. It fires a
  `t:Remedy.Consumer.guild_emojis_update/0` event.

  An optional `reason` can be provided for the audit log.

  If successful, returns `{:ok, emoji}`. Otherwise, returns `t:Remedy.Api.error/0`.

  ## Options

    * `:name` (string) - name of the emoji
    * `:roles` (list of `t:Sunbake.Snowflake.t/0`) - roles to which this emoji will be whitelisted

  ## Examples

  ```Elixir
  Remedy.Api.modify_guild_emoji(43189401384091, 4314301984301, name: "elixir", roles: [])
  ```
  """

  @spec modify_guild_emoji(Guild.id(), Emoji.id(), options, AuditLogEntry.reason()) ::
          error | {:ok, Emoji.t()}
  def modify_guild_emoji(guild_id, emoji_id, options \\ %{}, reason \\ nil)

  def modify_guild_emoji(guild_id, emoji_id, options, reason) when is_list(options),
    do: modify_guild_emoji(guild_id, emoji_id, Map.new(options), reason)

  def modify_guild_emoji(guild_id, emoji_id, %{} = options, reason) do
    %{
      method: :patch,
      route: Endpoints.guild_emoji(guild_id, emoji_id),
      body: options,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode({:struct, Emoji})
  end

  @doc ~S"""
  Deletes the given emoji.

  An optional `reason` can be provided for the audit log.

  This endpoint requires the `MANAGE_EMOJIS` permission. It fires a
  `t:Remedy.Consumer.guild_emojis_update/0` event.

  If successful, returns `{:ok}`. Otherwise, returns `t:Remedy.Api.error/0`.
  """

  @spec delete_guild_emoji(Guild.id(), Emoji.id(), AuditLogEntry.reason()) :: error | {:ok}
  def delete_guild_emoji(guild_id, emoji_id, reason \\ nil),
    do:
      request(%{
        method: :delete,
        route: Endpoints.guild_emoji(guild_id, emoji_id),
        body: "",
        options: [],
        headers: maybe_add_reason(reason)
      })

  @doc ~S"""
  Get the `t:Remedy.Struct.Guild.AuditLog.t/0` for the given `guild_id`.

  ## Options

    * `:user_id` (`t:Remedy.Struct.User.id/0`) - filter the log for a user ID
    * `:action_type` (`t:integer/0`) - filter the log by audit log type, see [Audit Log Events](https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events)
    * `:before` (`t:Remedy.Struct.Snowflake.t/0`) - filter the log before a certain entry ID
    * `:limit` (`t:pos_integer/0`) - how many entries are returned (default 50, minimum 1, maximum 100)
  """

  @spec get_guild_audit_log(Guild.id(), options) :: {:ok, AuditLog.t()} | error
  def get_guild_audit_log(guild_id, options \\ []) do
    request(:get, Endpoints.guild_audit_logs(guild_id), "", params: options)
    |> handle_request_with_decode({:struct, AuditLog})
  end

  @doc ~S"""
  Gets a guild.

  If successful, returns `{:ok, guild}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_guild(81384788765712384)
  {:ok, %Remedy.Struct.Guild{id: 81384788765712384}}
  ```
  """

  @spec get_guild(Guild.id()) :: error | {:ok, Guild.rest_guild()}
  def get_guild(guild_id) when is_snowflake(guild_id) do
    request(:get, Endpoints.guild(guild_id))
    |> handle_request_with_decode({:struct, Guild})
  end

  @doc """
  Modifies a guild's settings.

  This endpoint requires the `MANAGE_GUILD` permission. It fires the
  `t:Remedy.Consumer.guild_update/0` event.

  An optional `reason` can be provided for the audit log.

  If successful, returns `{:ok, guild}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:name` (string) - guild name
    * `:region` (string) - guild voice region id
    * `:verification_level` (integer) - verification level
    * `:default_message_notifications` (integer) - default message
    notification level
    * `:explicit_content_filter` (integer) - explicit content filter level
    * `:afk_channel_id` (`t:Sunbake.Snowflake.t/0`) - id for afk channel
    * `:afk_timeout` (integer) - afk timeout in seconds
    * `:icon` (base64 data URI) - 128x128 jpeg image for the guild icon
    * `:owner_id` (`t:Sunbake.Snowflake.t/0`) - user id to transfer
    guild ownership to (must be owner)
    * `:splash` (base64 data URI) - 128x128 jpeg image for the guild splash
    (VIP only)
    * `:system_channel_id` (`t:Sunbake.Snowflake.t/0`) - the id of the
    channel to which system messages are sent
    * `:rules_channel_id` (`t:Sunbake.Snowflake.t/0`) - the id of the channel that
    is used for rules in public guilds
    * `:public_updates_channel_id` (`t:Sunbake.Snowflake.t/0`) - the id of the channel
    where admins and moderators receive notices from Discord in public guilds

  ## Examples

  ```elixir
  Remedy.Api.modify_guild(451824027976073216, name: "Nose Drum")
  {:ok, %Remedy.Struct.Guild{id: 451824027976073216, name: "Nose Drum", ...}}
  ```
  """

  @spec modify_guild(Guild.id(), options, AuditLogEntry.reason()) ::
          error | {:ok, Guild.rest_guild()}
  def modify_guild(guild_id, options \\ [], reason \\ nil)

  def modify_guild(guild_id, options, reason) when is_list(options),
    do: modify_guild(guild_id, Map.new(options), reason)

  def modify_guild(guild_id, options, reason) when is_snowflake(guild_id) and is_map(options) do
    options = Map.new(options)

    %{
      method: :patch,
      route: Endpoints.guild(guild_id),
      body: options,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode({:struct, Guild})
  end

  @doc ~S"""
  Deletes a guild.

  This endpoint requires that the current user is the owner of the guild.
  It fires the `t:Remedy.Consumer.guild_delete/0` event.

  If successful, returns `{:ok}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.delete_guild(81384788765712384)
  {:ok}
  ```
  """

  @spec delete_guild(Guild.id()) :: error | {:ok}
  def delete_guild(guild_id) when is_snowflake(guild_id) do
    request(:delete, Endpoints.guild(guild_id))
  end

  @doc ~S"""
  Gets a list of guild channels.

  If successful, returns `{:ok, channels}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_guild_channels(81384788765712384)
  {:ok, [%Remedy.Struct.Channel{guild_id: 81384788765712384} | _]}
  ```
  """

  @spec get_guild_channels(Guild.id()) :: error | {:ok, [Channel.guild_channel()]}
  def get_guild_channels(guild_id) when is_snowflake(guild_id) do
    request(:get, Endpoints.guild_channels(guild_id))
    |> handle_request_with_decode({:list, {:struct, Channel}})
  end

  @doc """
  Creates a channel for a guild.

  This endpoint requires the `MANAGE_CHANNELS` permission. It fires a
  `t:Remedy.Consumer.channel_create/0` event.

  If successful, returns `{:ok, channel}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:name` (string) - channel name (2-100 characters)
    * `:type` (integer) - the type of channel (See `Remedy.Struct.Channel`)
    * `:topic` (string) - channel topic (0-1024 characters)
    * `:bitrate` (integer) - the bitrate (in bits) of the voice channel (voice only)
    * `:user_limit` (integer) - the user limit of the voice channel (voice only)
    * `:permission_overwrites` (list of `t:Remedy.Struct.Overwrite.t/0` or equivalent map) -
    the channel's permission overwrites
    * `:parent_id` (`t:Remedy.Struct.Channel.id/0`) - id of the parent category for a channel
    * `:nsfw` (boolean) - if the channel is nsfw

  `:name` is always required.

  ## Examples

  ```Elixir
  Remedy.Api.create_guild_channel(81384788765712384, name: "elixir-remedy", topic: "craig's domain")
  {:ok, %Remedy.Struct.Channel{guild_id: 81384788765712384}}
  ```
  """

  @spec create_guild_channel(Guild.id(), options) :: error | {:ok, Channel.guild_channel()}
  def create_guild_channel(guild_id, options)

  def create_guild_channel(guild_id, options) when is_list(options),
    do: create_guild_channel(guild_id, Map.new(options))

  def create_guild_channel(guild_id, %{} = options) when is_snowflake(guild_id) do
    request(:post, Endpoints.guild_channels(guild_id), options)
    |> handle_request_with_decode({:struct, Channel})
  end

  @doc """
  Reorders a guild's channels.

  This endpoint requires the `MANAGE_CHANNELS` permission. It fires multiple
  `t:Remedy.Consumer.channel_update/0` events.

  If successful, returns `{:ok, channels}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  `positions` is a list of maps that each map a channel id with a position.

  ## Examples

  ```Elixir
  Remedy.Api.modify_guild_channel_positions(279093381723062272, [%{id: 351500354581692420, position: 2}])
  {:ok}
  ```
  """

  @spec modify_guild_channel_positions(Guild.id(), [%{id: integer, position: integer}]) ::
          error | {:ok}
  def modify_guild_channel_positions(guild_id, positions)
      when is_snowflake(guild_id) and is_list(positions) do
    request(:patch, Endpoints.guild_channels(guild_id), positions)
  end

  @doc """
  Gets a guild member.

  If successful, returns `{:ok, member}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_guild_member(4019283754613, 184937267485)
  ```
  """

  @spec get_guild_member(Guild.id(), User.id()) :: error | {:ok, Member.t()}
  def get_guild_member(guild_id, user_id) when is_snowflake(guild_id) and is_snowflake(user_id) do
    request(:get, Endpoints.guild_member(guild_id, user_id))
    |> handle_request_with_decode({:struct, Member})
  end

  @doc """
  Gets a list of a guild's members.

  If successful, returns `{:ok, members}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:limit` (integer) - max number of members to return (1-1000) (default: 1)
    * `:after` (`t:Remedy.Struct.User.id/0`) - the highest user id in the previous page (default: 0)

  ## Examples

  ```Elixir
  Remedy.Api.list_guild_members(41771983423143937, limit: 1)
  ```
  """

  @spec list_guild_members(Guild.id(), options) :: error | {:ok, [Member.t()]}
  def list_guild_members(guild_id, options \\ %{})

  def list_guild_members(guild_id, options) when is_list(options),
    do: list_guild_members(guild_id, Map.new(options))

  def list_guild_members(guild_id, %{} = options) when is_snowflake(guild_id) do
    request(:get, Endpoints.guild_members(guild_id), "", params: options)
    |> handle_request_with_decode({:list, {:struct, Member}})
  end

  @doc ~S"""
  Puts a user in a guild.

  This endpoint fires the `t:Remedy.Consumer.guild_member_add/0` event.
  It requires the `CREATE_INSTANT_INVITE` permission. Additionally, it
  situationally requires the `MANAGE_NICKNAMES`, `MANAGE_ROLES`,
  `MUTE_MEMBERS`, and `DEAFEN_MEMBERS` permissions.

  If successful, returns `{:ok, member}` or `{:ok}` if the user was already a member of the
  guild. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:access_token` (string) - the user's oauth2 access token
    * `:nick` (string) - value to set users nickname to
    * `:roles` (list of `t:Remedy.Struct.Guild.Role.id/0`) - array of role ids the member is assigned
    * `:mute` (boolean) - if the user is muted
    * `:deaf` (boolean) - if the user is deafened

  `:access_token` is always required.

  ## Examples

  ```Elixir
  Remedy.Api.add_guild_member(
    41771983423143937,
    18374719829378473,
    access_token: "6qrZcUqja7812RVdnEKjpzOL4CvHBFG",
    nick: "remedy",
    roles: [431849301, 913809431]
  )
  ```
  """

  @spec add_guild_member(Guild.id(), User.id(), options) :: error | {:ok, Member.t()} | {:ok}
  def add_guild_member(guild_id, user_id, options)

  def add_guild_member(guild_id, user_id, options) when is_list(options),
    do: add_guild_member(guild_id, user_id, Map.new(options))

  def add_guild_member(guild_id, user_id, %{} = options)
      when is_snowflake(guild_id) and is_snowflake(user_id) do
    request(:put, Endpoints.guild_member(guild_id, user_id), options)
    |> handle_request_with_decode({:struct, Member})
  end

  @doc ~S"""
  Modifies a guild member's attributes.

  This endpoint fires the `t:Remedy.Consumer.guild_member_update/0` event.
  It situationally requires the `MANAGE_NICKNAMES`, `MANAGE_ROLES`,
  `MUTE_MEMBERS`, `DEAFEN_MEMBERS`, and `MOVE_MEMBERS` permissions.

  If successful, returns `{:ok}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:nick` (string) - value to set users nickname to
    * `:roles` (list of `t:Sunbake.Snowflake.t/0`) - array of role ids the member is assigned
    * `:mute` (boolean) - if the user is muted
    * `:deaf` (boolean) - if the user is deafened
    * `:channel_id` (`t:Sunbake.Snowflake.t/0`) - id of channel to move user to (if they are connected to voice)

  ## Examples

  ```Elixir
  Remedy.Api.modify_guild_member(41771983423143937, 637162356451, nick: "Remedy")
  {:ok}
  ```
  """

  @spec modify_guild_member(Guild.id(), User.id(), options) :: error | {:ok}
  def modify_guild_member(guild_id, user_id, options \\ %{})

  def modify_guild_member(guild_id, user_id, options) when is_list(options),
    do: modify_guild_member(guild_id, user_id, Map.new(options))

  def modify_guild_member(guild_id, user_id, %{} = options)
      when is_snowflake(guild_id) and is_snowflake(user_id) do
    request(:patch, Endpoints.guild_member(guild_id, user_id), options)
  end

  @doc """
  Modifies the nickname of the current user in a guild.

  If successful, returns `{:ok, %{nick: nick}}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:nick` (string) - value to set users nickname to

  ## Examples

  ```Elixir
  Remedy.Api.modify_current_user_nick(41771983423143937, nick: "Remedy")
  {:ok, %{nick: "Remedy"}}
  ```
  """

  @spec modify_current_user_nick(Guild.id(), options) :: error | {:ok, %{nick: String.t()}}
  def modify_current_user_nick(guild_id, options \\ %{}) do
    request(:patch, Endpoints.guild_me_nick(guild_id), options)
    |> handle_request_with_decode()
  end

  @doc """
  Adds a role to a member.

  Role to add is specified by `role_id`.
  User to add role to is specified by `guild_id` and `user_id`.
  An optional `reason` can be given for the audit log.
  """

  @spec add_guild_member_role(integer, integer, integer, AuditLogEntry.reason()) :: error | {:ok}
  def add_guild_member_role(guild_id, user_id, role_id, reason \\ nil) do
    request(%{
      method: :put,
      route: Endpoints.guild_member_role(guild_id, user_id, role_id),
      body: "",
      options: [],
      headers: maybe_add_reason(reason)
    })
  end

  @doc """
  Removes a role from a member.

  Role to remove is specified by `role_id`.
  User to remove role from is specified by `guild_id` and `user_id`.
  An optional `reason` can be given for the audit log.
  """

  @spec remove_guild_member_role(integer, integer, integer, AuditLogEntry.reason()) ::
          error | {:ok}
  def remove_guild_member_role(guild_id, user_id, role_id, reason \\ nil) do
    request(%{
      method: :delete,
      route: Endpoints.guild_member_role(guild_id, user_id, role_id),
      body: "",
      options: [],
      headers: maybe_add_reason(reason)
    })
  end

  @doc """
  Removes a member from a guild.

  This event requires the `KICK_MEMBERS` permission. It fires a
  `t:Remedy.Consumer.guild_member_remove/0` event.

  An optional reason can be provided for the audit log with `reason`.

  If successful, returns `{:ok}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.remove_guild_member(1453827904102291, 18739485766253)
  {:ok}
  ```
  """

  @spec remove_guild_member(Guild.id(), User.id(), AuditLogEntry.reason()) :: error | {:ok}
  def remove_guild_member(guild_id, user_id, reason \\ nil)
      when is_snowflake(guild_id) and is_snowflake(user_id) do
    request(%{
      method: :delete,
      route: Endpoints.guild_member(guild_id, user_id),
      body: "",
      options: [],
      headers: maybe_add_reason(reason)
    })
  end

  @doc """
  Gets a ban object for the given user from a guild.
  """

  @doc since: "0.5.0"
  @spec get_guild_ban(integer, integer) :: error | {:ok, Guild.Ban.t()}
  def get_guild_ban(guild_id, user_id) do
    request(:get, Endpoints.guild_ban(guild_id, user_id))
    |> handle_request_with_decode({:struct, Guild.Ban})
  end

  @doc """
  Gets a list of users banned from a guild.

  Guild to get bans for is specified by `guild_id`.
  """

  @spec get_guild_bans(integer) :: error | {:ok, [Remedy.Struct.User.t()]}
  def get_guild_bans(guild_id) do
    request(:get, Endpoints.guild_bans(guild_id))
    |> handle_request_with_decode
  end

  @doc """
  Bans a user from a guild.

  User to delete is specified by `guild_id` and `user_id`.
  An optional `reason` can be specified for the audit log.
  """

  @spec create_guild_ban(integer, integer, integer, AuditLogEntry.reason()) :: error | {:ok}
  def create_guild_ban(guild_id, user_id, days_to_delete, reason \\ nil) do
    request(%{
      method: :put,
      route: Endpoints.guild_ban(guild_id, user_id),
      body: %{"delete-message-days": days_to_delete},
      options: [],
      headers: maybe_add_reason(reason)
    })
  end

  @doc """
  Removes a ban for a user.

  User to unban is specified by `guild_id` and `user_id`.
  An optional `reason` can be specified for the audit log.
  """

  @spec remove_guild_ban(integer, integer, AuditLogEntry.reason()) :: error | {:ok}
  def remove_guild_ban(guild_id, user_id, reason \\ nil) do
    request(%{
      method: :delete,
      route: Endpoints.guild_ban(guild_id, user_id),
      body: "",
      options: [],
      headers: maybe_add_reason(reason)
    })
  end

  @doc ~S"""
  Gets a guild's roles.

  If successful, returns `{:ok, roles}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_guild_roles(147362948571673)
  ```
  """

  @spec get_guild_roles(Guild.id()) :: error | {:ok, [Role.t()]}
  def get_guild_roles(guild_id) when is_snowflake(guild_id) do
    request(:get, Endpoints.guild_roles(guild_id))
    |> handle_request_with_decode({:list, {:struct, Role}})
  end

  @doc ~S"""
  Creates a guild role.

  An optional reason for the audit log can be provided via `reason`.

  This endpoint requires the `MANAGE_ROLES` permission. It fires a
  `t:Remedy.Consumer.guild_role_create/0` event.

  If successful, returns `{:ok, role}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:name` (string) - name of the role (default: "new role")
    * `:permissions` (integer) - bitwise of the enabled/disabled permissions (default: @everyone perms)
    * `:color` (integer) - RGB color value (default: 0)
    * `:hoist` (boolean) - whether the role should be displayed separately in the sidebar (default: false)
    * `:mentionable` (boolean) - whether the role should be mentionable (default: false)

  ## Examples

  ```Elixir
  Remedy.Api.create_guild_role(41771983423143937, name: "remedy-club", hoist: true)
  ```
  """

  @spec create_guild_role(Guild.id(), options, AuditLogEntry.reason()) :: error | {:ok, Role.t()}
  def create_guild_role(guild_id, options, reason \\ nil)

  def create_guild_role(guild_id, options, reason) when is_list(options),
    do: create_guild_role(guild_id, Map.new(options), reason)

  def create_guild_role(guild_id, %{} = options, reason) when is_snowflake(guild_id) do
    %{
      method: :post,
      route: Endpoints.guild_roles(guild_id),
      body: options,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode({:struct, Role})
  end

  @doc ~S"""
  Reorders a guild's roles.

  This endpoint requires the `MANAGE_ROLES` permission. It fires multiple
  `t:Remedy.Consumer.guild_role_update/0` events.

  If successful, returns `{:ok, roles}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  `positions` is a list of maps that each map a role id with a position.

  ## Examples

  ```Elixir
  Remedy.Api.modify_guild_role_positions(41771983423143937, [%{id: 41771983423143936, position: 2}])
  ```
  """

  @spec modify_guild_role_positions(
          Guild.id(),
          [%{id: Role.id(), position: integer}],
          AuditLogEntry.reason()
        ) :: error | {:ok, [Role.t()]}
  def modify_guild_role_positions(guild_id, positions, reason \\ nil)
      when is_snowflake(guild_id) and is_list(positions) do
    %{
      method: :patch,
      route: Endpoints.guild_roles(guild_id),
      body: positions,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode({:list, {:struct, Role}})
  end

  @doc ~S"""
  Modifies a guild role.

  This endpoint requires the `MANAGE_ROLES` permission. It fires a
  `t:Remedy.Consumer.guild_role_update/0` event.

  An optional `reason` can be specified for the audit log.

  If successful, returns `{:ok, role}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:name` (string) - name of the role
    * `:permissions` (integer) - bitwise of the enabled/disabled permissions
    * `:color` (integer) - RGB color value (default: 0)
    * `:hoist` (boolean) - whether the role should be displayed separately in the sidebar
    * `:mentionable` (boolean) - whether the role should be mentionable

  ## Examples

  ```Elixir
  Remedy.Api.modify_guild_role(41771983423143937, 392817238471936, hoist: false, name: "foo-bar")
  ```
  """

  @spec modify_guild_role(Guild.id(), Role.id(), options, AuditLogEntry.reason()) ::
          error | {:ok, Role.t()}
  def modify_guild_role(guild_id, role_id, options, reason \\ nil)

  def modify_guild_role(guild_id, role_id, options, reason) when is_list(options),
    do: modify_guild_role(guild_id, role_id, Map.new(options), reason)

  def modify_guild_role(guild_id, role_id, %{} = options, reason)
      when is_snowflake(guild_id) and is_snowflake(role_id) do
    %{
      method: :patch,
      route: Endpoints.guild_role(guild_id, role_id),
      body: options,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode({:struct, Role})
  end

  @doc ~S"""
  Deletes a role from a guild.

  An optional `reason` can be specified for the audit log.

  This endpoint requires the `MANAGE_ROLES` permission. It fires a
  `t:Remedy.Consumer.guild_role_delete/0` event.

  If successful, returns `{:ok}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.delete_guild_role(41771983423143937, 392817238471936)
  ```
  """

  @spec delete_guild_role(Guild.id(), Role.id(), AuditLogEntry.reason()) :: error | {:ok}
  def delete_guild_role(guild_id, role_id, reason \\ nil)
      when is_snowflake(guild_id) and is_snowflake(role_id) do
    request(%{
      method: :delete,
      route: Endpoints.guild_role(guild_id, role_id),
      body: "",
      options: [],
      headers: maybe_add_reason(reason)
    })
  end

  @doc """
  Gets the number of members that would be removed in a prune given `days`.

  This endpoint requires the `KICK_MEMBERS` permission.

  If successful, returns `{:ok, %{pruned: pruned}}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_guild_prune_count(81384788765712384, 1)
  {:ok, %{pruned: 0}}
  ```
  """

  @spec get_guild_prune_count(Guild.id(), 1..30) :: error | {:ok, %{pruned: integer}}
  def get_guild_prune_count(guild_id, days) when is_snowflake(guild_id) and days in 1..30 do
    request(:get, Endpoints.guild_prune(guild_id), "", params: [days: days])
    |> handle_request_with_decode
  end

  @doc """
  Begins a guild prune to prune members within `days`.

  An optional `reason` can be provided for the guild audit log.

  This endpoint requires the `KICK_MEMBERS` permission. It fires multiple
  `t:Remedy.Consumer.guild_member_remove/0` events.

  If successful, returns `{:ok, %{pruned: pruned}}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.begin_guild_prune(81384788765712384, 1)
  {:ok, %{pruned: 0}}
  ```
  """

  @spec begin_guild_prune(Guild.id(), 1..30, AuditLogEntry.reason()) ::
          error | {:ok, %{pruned: integer}}
  def begin_guild_prune(guild_id, days, reason \\ nil)
      when is_snowflake(guild_id) and days in 1..30 do
    %{
      method: :post,
      route: Endpoints.guild_prune(guild_id),
      body: "",
      options: [params: [days: days]],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode
  end

  @doc """
  Gets a list of voice regions for the guild.

  Guild to get voice regions for is specified by `guild_id`.
  """

  @spec get_voice_region(integer) :: error | {:ok, [Remedy.Struct.VoiceRegion.t()]}
  def get_voice_region(guild_id) do
    request(:get, Endpoints.guild_voice_regions(guild_id))
    |> handle_request_with_decode
  end

  @doc ~S"""
  Gets a list of invites for a guild.

  This endpoint requires the `MANAGE_GUILD` permission.

  If successful, returns `{:ok, invites}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_guild_invites(81384788765712384)
  {:ok, [%Remedy.Struct.Invite{} | _]}
  ```
  """

  @spec get_guild_invites(Guild.id()) :: error | {:ok, [Invite.detailed_invite()]}
  def get_guild_invites(guild_id) when is_snowflake(guild_id) do
    request(:get, Endpoints.guild_invites(guild_id))
    |> handle_request_with_decode({:list, {:struct, Invite}})
  end

  @doc """
  Gets a list of guild integerations.

  Guild to get integrations for is specified by `guild_id`.
  """

  @spec get_guild_integrations(Guild.id()) ::
          error | {:ok, [Remedy.Struct.Guild.Integration.t()]}
  def get_guild_integrations(guild_id) do
    request(:get, Endpoints.guild_integrations(guild_id))
    |> handle_request_with_decode
  end

  @doc """
  Creates a new guild integeration.

  Guild to create integration with is specified by `guild_id`.

  `options` is a map with the following requires keys:
   * `type` - Integration type.
   * `id` - Integeration id.
  """

  @spec create_guild_integrations(integer, %{
          type: String.t(),
          id: integer
        }) :: error | {:ok}
  def create_guild_integrations(guild_id, options) do
    request(:post, Endpoints.guild_integrations(guild_id), options)
  end

  @doc """
  Changes the settings and behaviours for a guild integeration.

  Integration to modify is specified by `guild_id` and `integeration_id`.

  `options` is a map with the following keys:
   * `expire_behavior` - Expiry behavior.
   * `expire_grace_period` - Period where the integration will ignore elapsed subs.
   * `enable_emoticons` - Whether emoticons should be synced.
  """

  @spec modify_guild_integrations(integer, integer, %{
          expire_behaviour: integer,
          expire_grace_period: integer,
          enable_emoticons: boolean
        }) :: error | {:ok}
  def modify_guild_integrations(guild_id, integration_id, options) do
    request(:patch, Endpoints.guild_integration(guild_id, integration_id), options)
  end

  @doc """
  Deletes a guild integeration.

  Integration to delete is specified by `guild_id` and `integeration_id`.
  """

  @spec delete_guild_integrations(integer, integer) :: error | {:ok}
  def delete_guild_integrations(guild_id, integration_id) do
    request(:delete, Endpoints.guild_integration(guild_id, integration_id))
  end

  @doc """
  Syncs a guild integration.

  Integration to sync is specified by `guild_id` and `integeration_id`.
  """

  @spec sync_guild_integrations(integer, integer) :: error | {:ok}
  def sync_guild_integrations(guild_id, integration_id) do
    request(:post, Endpoints.guild_integration_sync(guild_id, integration_id))
  end

  @doc """
  Gets a guild embed.
  """

  @spec get_guild_embed(integer) :: error | {:ok, map}
  def get_guild_embed(guild_id) do
    request(:get, Endpoints.guild_embed(guild_id))
  end

  @doc """
  Modifies a guild embed.
  """

  @spec modify_guild_embed(integer, map) :: error | {:ok, map}
  def modify_guild_embed(guild_id, options) do
    request(:patch, Endpoints.guild_embed(guild_id), options)
    |> handle_request_with_decode
  end

  @doc ~S"""
  Gets an invite by its `invite_code`.

  If successful, returns `{:ok, invite}`. Otherwise, returns a
  `t:Remedy.Api.error/0`.

  ## Options

    * `:with_counts` (boolean) - whether to include member count fields

  ## Examples

  ```Elixir
  Remedy.Api.get_invite("zsjUsC")

  Remedy.Api.get_invite("zsjUsC", with_counts: true)
  ```
  """

  @spec get_invite(Invite.code(), options) :: error | {:ok, Invite.simple_invite()}
  def get_invite(invite_code, options \\ []) when is_binary(invite_code) do
    request(:get, Endpoints.invite(invite_code), "", params: options)
    |> handle_request_with_decode({:struct, Invite})
  end

  @doc ~S"""
  Deletes an invite by its `invite_code`.

  This endpoint requires the `MANAGE_CHANNELS` permission.

  If successful, returns `{:ok, invite}`. Otherwise, returns a
  `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.delete_invite("zsjUsC")
  ```
  """

  @spec delete_invite(Invite.code()) :: error | {:ok, Invite.simple_invite()}
  def delete_invite(invite_code) when is_binary(invite_code) do
    request(:delete, Endpoints.invite(invite_code))
    |> handle_request_with_decode({:struct, Invite})
  end

  @doc """
  Gets a user by its `t:Remedy.Struct.User.id/0`.

  If the request is successful, this function returns `{:ok, user}`, where
  `user` is a `Remedy.Struct.User`. Otherwise, returns `{:error, reason}`.
  """

  @spec get_user(User.id()) :: error | {:ok, User.t()}
  def get_user(user_id) do
    request(:get, Endpoints.user(user_id))
    |> handle_request_with_decode({:struct, User})
  end

  @doc """
  Gets info on the current user.

  If remedy's caching is enabled, it is recommended to use `Bot.get/0`
  instead of this function. This is because sending out an API request is much slower
  than pulling from our cache.

  If the request is successful, this function returns `{:ok, user}`, where
  `user` is remedy's `Remedy.Struct.User`. Otherwise, returns `{:error, reason}`.
  """

  @spec get_current_user() :: error | {:ok, User.t()}
  def get_current_user do
    request(:get, Endpoints.me())
    |> handle_request_with_decode({:struct, User})
  end

  @doc ~S"""
  Changes the username or avatar of the current user.

  ## Options

    * `:username` (string) - new username
    * `:avatar` (string) - the user's avatar as [avatar data](https://discord.com/developers/docs/resources/user#avatar-data)

  ## Examples

  ```Elixir
  Remedy.Api.modify_current_user(avatar: "data:image/jpeg;base64,YXl5IGJieSB1IGx1a2luIDQgc3VtIGZ1az8=")
  ```
  """

  @spec modify_current_user(options) :: error | {:ok, User.t()}
  def modify_current_user(options)

  def modify_current_user(options) when is_list(options),
    do: modify_current_user(Map.new(options))

  def modify_current_user(%{} = options) do
    request(:patch, Endpoints.me(), options)
    |> handle_request_with_decode({:struct, User})
  end

  @doc """
  Gets a list of guilds the user is currently in.

  This endpoint requires the `guilds` OAuth2 scope.

  If successful, returns `{:ok, guilds}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Options

    * `:before` (`t:Sunbake.Snowflake.t/0`) - get guilds before this
    guild ID
    * `:after` (`t:Sunbake.Snowflake.t/0`) - get guilds after this guild
    ID
    * `:limit` (integer) - max number of guilds to return (1-100)

  ## Examples

  ```Elixir
  iex> Remedy.Api.get_current_user_guilds(limit: 1)
  {:ok, [%Remedy.Struct.Guild{}]}
  ```
  """

  @spec get_current_user_guilds(options) :: error | {:ok, [Guild.user_guild()]}
  def get_current_user_guilds(options \\ [])

  def get_current_user_guilds(options) when is_list(options),
    do: get_current_user_guilds(Map.new(options))

  def get_current_user_guilds(options) when is_map(options) do
    request(:get, Endpoints.me_guilds(), "", params: options)
    |> handle_request_with_decode({:list, {:struct, Guild}})
  end

  @doc """
  Leaves a guild.

  Guild to leave is specified by `guild_id`.
  """

  @spec leave_guild(integer) :: error | {:ok}
  def leave_guild(guild_id) do
    request(%{
      method: :delete,
      route: Endpoints.me_guild(guild_id),
      body: "",
      options: [],
      headers: []
    })
  end

  @doc """
  Gets a list of our user's DM channels.

  If successful, returns `{:ok, dm_channels}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.get_user_dms()
  {:ok, [%Remedy.Struct.Channel{type: 1} | _]}
  ```
  """

  @spec get_user_dms() :: error | {:ok, [Channel.dm_channel()]}
  def get_user_dms do
    request(:get, Endpoints.me_channels())
    |> handle_request_with_decode({:list, {:struct, Channel}})
  end

  @doc ~S"""
  Create a new DM channel with a user.

  If successful, returns `{:ok, dm_channel}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  ## Examples

  ```Elixir
  Remedy.Api.create_dm(150061853001777154)
  {:ok, %Remedy.Struct.Channel{type: 1}}
  ```
  """

  @spec create_dm(User.id()) :: error | {:ok, Channel.dm_channel()}
  def create_dm(user_id) when is_snowflake(user_id) do
    request(:post, Endpoints.me_channels(), %{recipient_id: user_id})
    |> handle_request_with_decode({:struct, Channel})
  end

  @doc """
  Creates a new group DM channel.

  If successful, returns `{:ok, group_dm_channel}`. Otherwise, returns a `t:Remedy.Api.error/0`.

  `access_tokens` are user oauth2 tokens. `nicks` is a map that maps a user id
  to a nickname.

  ## Examples

  ```Elixir
  Remedy.Api.create_group_dm(["6qrZcUqja7812RVdnEKjpzOL4CvHBFG"], %{41771983423143937 => "My Nickname"})
  {:ok, %Remedy.Struct.Channel{type: 3}}
  ```
  """

  @spec create_group_dm([String.t()], %{optional(User.id()) => String.t()}) ::
          error | {:ok, Channel.group_dm_channel()}
  def create_group_dm(access_tokens, nicks) when is_list(access_tokens) and is_map(nicks) do
    request(:post, Endpoints.me_channels(), %{access_tokens: access_tokens, nicks: nicks})
    |> handle_request_with_decode({:struct, Channel})
  end

  @doc """
  Gets a list of user connections.
  """

  @spec get_user_connections() :: error | {:ok, list()}
  def get_user_connections do
    request(:get, Endpoints.me_connections())
    |> handle_request_with_decode
  end

  @doc """
  Gets a list of voice regions.
  """

  @spec list_voice_regions() :: error | {:ok, [Remedy.Struct.VoiceRegion.t()]}
  def list_voice_regions do
    request(:get, Endpoints.regions())
    |> handle_request_with_decode
  end

  @doc """
  Creates a webhook.

  ## Parameters
    - `channel_id` - Id of the channel to send the message to.
    - `args` - Map with the following **required** keys:
      - `name` - Name of the webhook.
      - `avatar` - Base64 128x128 jpeg image for the default avatar.
    - `reason` - An optional reason for the guild audit log.
  """

  @spec create_webhook(
          Channel.id(),
          %{
            name: String.t(),
            avatar: String.t()
          },
          AuditLogEntry.reason()
        ) :: error | {:ok, Remedy.Struct.Webhook.t()}
  def create_webhook(channel_id, args, reason \\ nil) do
    %{
      method: :post,
      route: Endpoints.webhooks_channel(channel_id),
      body: args,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode
  end

  @doc """
  Gets a list of webook for a channel.

  ## Parameters
    - `channel_id` - Channel to get webhooks for.
  """

  @spec get_channel_webhooks(Channel.id()) :: error | {:ok, [Remedy.Struct.Webhook.t()]}
  def get_channel_webhooks(channel_id) do
    request(:get, Endpoints.webhooks_channel(channel_id))
    |> handle_request_with_decode
  end

  @doc """
  Gets a list of webooks for a guild.

  ## Parameters
    - `guild_id` - Guild to get webhooks for.
  """

  @spec get_guild_webhooks(Guild.id()) :: error | {:ok, [Remedy.Struct.Webhook.t()]}
  def get_guild_webhooks(guild_id) do
    request(:get, Endpoints.webhooks_guild(guild_id))
    |> handle_request_with_decode
  end

  @doc """
  Gets a webhook by id.

  ## Parameters
    - `webhook_id` - Id of the webhook to get.
  """

  @spec get_webhook(Webhook.id()) :: error | {:ok, Remedy.Struct.Webhook.t()}
  def get_webhook(webhook_id) do
    request(:get, Endpoints.webhook(webhook_id))
    |> handle_request_with_decode
  end

  @doc """
  Gets a webhook by id and token.

  This method is exactly like `get_webhook/1` but does not require
  authentication.

  ## Parameters
    - `webhook_id` - Id of the webhook to get.
    - `webhook_token` - Token of the webhook to get.
  """

  @spec get_webhook_with_token(Webhook.id(), Webhook.token()) ::
          error | {:ok, Remedy.Struct.Webhook.t()}
  def get_webhook_with_token(webhook_id, webhook_token) do
    request(:get, Endpoints.webhook_token(webhook_id, webhook_token))
    |> handle_request_with_decode
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

  @spec modify_webhook(
          Webhook.id(),
          %{
            name: String.t(),
            avatar: String.t()
          },
          AuditLogEntry.reason()
        ) :: error | {:ok, Remedy.Struct.Webhook.t()}
  def modify_webhook(webhook_id, args, reason \\ nil) do
    %{
      method: :patch,
      route: Endpoints.webhook(webhook_id),
      body: args,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode
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

  @spec modify_webhook_with_token(
          Webhook.id(),
          Webhook.token(),
          %{
            name: String.t(),
            avatar: String.t()
          },
          AuditLogEntry.reason()
        ) :: error | {:ok, Remedy.Struct.Webhook.t()}
  def modify_webhook_with_token(webhook_id, webhook_token, args, reason \\ nil) do
    %{
      method: :patch,
      route: Endpoints.webhook_token(webhook_id, webhook_token),
      body: args,
      options: [],
      headers: maybe_add_reason(reason)
    }
    |> request()
    |> handle_request_with_decode
  end

  @doc """
  Deletes a webhook.

  ## Parameters
    - `webhook_id` - Id of webhook to delete.
    - `reason` - An optional reason for the guild audit log.
  """

  @spec delete_webhook(Webhook.id(), AuditLogEntry.reason()) :: error | {:ok}
  def delete_webhook(webhook_id, reason \\ nil) do
    request(%{
      method: :delete,
      route: Endpoints.webhook(webhook_id),
      body: "",
      options: [],
      headers: maybe_add_reason(reason)
    })
  end

  @typep m1 :: %{
           required(:content) => String.t(),
           :username => String.t(),
           :avatar_url => String.t(),
           :tts => boolean,
           optional(:file) => String.t() | nil,
           optional(:embeds) => nonempty_list(Embed.t()) | nil
         }

  @typep m2 ::
           %{
             optional(:content) => String.t() | nil,
             :username => String.t(),
             :avatar_url => String.t(),
             :tts => boolean,
             required(:file) => String.t(),
             optional(:embeds) => nonempty_list(Embed.t()) | nil
           }

  @typep m3 ::
           %{
             optional(:content) => String.t() | nil,
             :username => String.t(),
             :avatar_url => String.t(),
             :tts => boolean,
             optional(:file) => String.t() | nil,
             required(:embeds) => nonempty_list(Embed.t())
           }

  @type matrix :: m1 | m2 | m3

  @spec execute_webhook(
          Webhook.id() | User.id(),
          Webhook.token() | Interaction.token(),
          matrix,
          boolean
        ) ::
          error | {:ok}

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

  def execute_webhook(webhook_id, webhook_token, args, wait \\ false)

  def execute_webhook(webhook_id, webhook_token, %{file: _} = args, wait) do
    request_multipart(
      :post,
      Endpoints.webhook_token(webhook_id, webhook_token),
      args,
      params: [wait: wait]
    )
  end

  def execute_webhook(webhook_id, webhook_token, %{content: _} = args, wait) do
    request(
      :post,
      Endpoints.webhook_token(webhook_id, webhook_token),
      args,
      params: [wait: wait]
    )
  end

  @doc """
  Executes a slack webhook.

  ## Parameters
    - `webhook_id` - Id of the webhook to execute.
    - `webhook_token` - Token of the webhook to execute.
  """

  @spec execute_slack_webhook(Webhook.id(), Webhook.token(), boolean) :: error | {:ok}
  def execute_slack_webhook(webhook_id, webhook_token, wait \\ false) do
    request(:post, Endpoints.webhook_slack(webhook_id, webhook_token), params: [wait: wait])
  end

  @doc """
  Executes a git webhook.

  ## Parameters
    - `webhook_id` - Id of the webhook to execute.
    - `webhook_token` - Token of the webhook to execute.
  """

  @spec execute_git_webhook(Webhook.id(), Webhook.token(), boolean) :: error | {:ok}
  def execute_git_webhook(webhook_id, webhook_token, wait \\ false) do
    request(:post, Endpoints.webhook_git(webhook_id, webhook_token), params: [wait: wait])
  end

  @doc """
  Gets the bot's OAuth2 application info.

  ## Example
  ```elixir
  Remedy.Api.get_application_information
  {:ok,
  %{
    bot_public: false,
    bot_require_code_grant: false,
    description: "Test",
    icon: nil,
    id: "172150183260323840",
    name: "Baba O-Riley",
    owner: %{
      avatar: nil,
      discriminator: "0042",
      id: "172150183260323840",
      username: "i own a bot"
    },
  }}
  ```
  """

  @spec get_application_information() :: error | {:ok, map()}
  def get_application_information do
    request(:get, Endpoints.application_information())
    |> handle_request_with_decode
  end

  @doc """
  Fetch all global commands.

  ## Parameters
  - `application_id`: Application ID for which to search commands.
    If not given, this will be fetched from `Me`.

  ## Return value
  A list of ``ApplicationCommand``s on success. See the official reference:
  https://discord.com/developers/docs/interactions/slash-commands#applicationcommand

  ## Example

  ```elixir
  iex> Remedy.Api.get_global_application_commands
  {:ok,
   [
     %{
       application_id: "455589479713865749",
       description: "ed, man! man, ed",
       id: "789841753196331029",
       name: "edit"
     }
   ]}
  ```
  """

  @spec get_global_application_commands() :: {:ok, [map()]} | error
  @spec get_global_application_commands(User.id()) :: {:ok, [map()]} | error
  def get_global_application_commands(application_id \\ Bot.get().id) do
    request(:get, Endpoints.global_application_commands(application_id))
    |> handle_request_with_decode
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

  ```elixir
  Remedy.Api.create_application_command(
    %{name: "edit", description: "ed, man! man, ed", options: []}
  )
  ```
  """

  @spec create_global_application_command(map()) :: {:ok, map()} | error
  @spec create_global_application_command(User.id(), map()) :: {:ok, map()} | error
  def create_global_application_command(application_id \\ Bot.get().id, command) do
    request(:post, Endpoints.global_application_commands(application_id), command)
    |> handle_request_with_decode
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

  @spec edit_global_application_command(Snowflake.t(), map()) :: {:ok, map()} | error
  @spec edit_global_application_command(User.id(), Snowflake.t(), map()) :: {:ok, map()} | error
  def edit_global_application_command(
        application_id \\ Bot.get().id,
        command_id,
        command
      ) do
    request(:patch, Endpoints.global_application_command(application_id, command_id), command)
    |> handle_request_with_decode
  end

  @doc """
  Delete an existing global application command.

  ## Parameters
  - `application_id`: Application ID for which to create the command.
    If not given, this will be fetched from `Me`.
  - `command_id`: The current snowflake of the command.
  """

  @spec delete_global_application_command(Snowflake.t()) :: {:ok} | error
  @spec delete_global_application_command(User.id(), Snowflake.t()) :: {:ok} | error
  def delete_global_application_command(application_id \\ Bot.get().id, command_id) do
    request(:delete, Endpoints.global_application_command(application_id, command_id))
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

  @doc since: "0.5.0"
  @spec bulk_overwrite_global_application_commands([map()]) :: {:ok, [map()]} | error
  @spec bulk_overwrite_global_application_commands(User.id(), [map()]) :: {:ok, [map()]} | error
  def bulk_overwrite_global_application_commands(application_id \\ Bot.get().id, commands) do
    request(:put, Endpoints.global_application_commands(application_id), commands)
    |> handle_request_with_decode
  end

  @spec get_guild_application_commands(Guild.id()) :: {:ok, [map()]} | error
  @spec get_guild_application_commands(User.id(), Guild.id()) :: {:ok, [map()]} | error
  def get_guild_application_commands(application_id \\ Bot.get().id, guild_id) do
    request(:get, Endpoints.guild_application_commands(application_id, guild_id))
    |> handle_request_with_decode
  end

  @spec create_guild_application_command(Guild.id(), map()) :: {:ok, map()} | error
  @spec create_guild_application_command(User.id(), Guild.id(), map()) :: {:ok, map()} | error
  def create_guild_application_command(
        application_id \\ Bot.get().id,
        guild_id,
        command
      ) do
    request(:post, Endpoints.guild_application_commands(application_id, guild_id), command)
    |> handle_request_with_decode
  end

  @spec edit_guild_application_command(Guild.id(), Snowflake.t(), map()) :: {:ok, map()} | error
  @spec edit_guild_application_command(User.id(), Guild.id(), Snowflake.t(), map()) ::
          {:ok, map()} | error
  def edit_guild_application_command(
        application_id \\ Bot.get().id,
        guild_id,
        command_id,
        command
      ) do
    request(
      :patch,
      Endpoints.guild_application_command(application_id, guild_id, command_id),
      command
    )
    |> handle_request_with_decode
  end

  @spec delete_guild_application_command(User.id(), Guild.id(), Snowflake.t()) :: {:ok} | error
  def delete_guild_application_command(
        application_id \\ Bot.get().id,
        guild_id,
        command_id
      ) do
    request(:delete, Endpoints.guild_application_command(application_id, guild_id, command_id))
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

  @doc since: "0.5.0"
  @spec bulk_overwrite_guild_application_commands(Guild.id(), [map()]) :: {:ok, [map()]} | error
  @spec bulk_overwrite_guild_application_commands(User.id(), Guild.id(), [map()]) ::
          {:ok, [map()]} | error
  def bulk_overwrite_guild_application_commands(
        application_id \\ Bot.get().id,
        guild_id,
        commands
      ) do
    request(:put, Endpoints.guild_application_commands(application_id, guild_id), commands)
    |> handle_request_with_decode
  end

  # Why the two separate functions here?
  # For the standard use case of "responding to an interaction retrieved
  # from the gateway", `create_interaction_response/2` is perfectly
  # sufficient. However, when one, for instance, uses Remedy in a web
  # service, or wants to respond to interactions at a later point in time,
  # we do not want the user to manually have to reconstruct interactions.
  @doc """
  Same as `create_interaction_response/3`, but directly takes the
  `t:Remedy.Struct.Interaction.t/0` received from the gateway.
  """

  @spec create_interaction_response(Interaction.t(), map()) :: {:ok} | error
  def create_interaction_response(interaction, response) do
    create_interaction_response(interaction.id, interaction.token, response)
  end

  @doc """
  Create a response to an interaction received from the gateway.

  ## Parameters
  - `id`: The interaction ID to which the response should be created.
  - `token`: The interaction token.
  - `response`: An [`InteractionResponse`](https://discord.com/developers/docs/interactions/slash-commands#interaction-interaction-response)
    object. See the linked documentation.

  ## Example

  ```elixir
  response = %{
    type: 4,
    data: %{
      content: "I copy and pasted this code."
    }
  }
  Remedy.Api.create_interaction_response(interaction, response)
  ```

  As an alternative to passing the interaction ID and token, the
  original `t:Remedy.Struct.Interaction.t/0` can also be passed
  directly. See `create_interaction_response/1`.
  """

  @spec create_interaction_response(Interaction.id(), Interaction.token(), map()) :: {:ok} | error
  def create_interaction_response(id, token, response) do
    request(:post, Endpoints.interaction_callback(id, token), response)
  end

  # edit original interaction response is purposefully not implemented
  # at the moment, waiting for "edit webhook message" first

  @doc """
  Create a followup message for an interaction.

  Delegates to ``execute_webhook/3``, see the function for more details.
  """

  @spec create_followup_message(Interaction.token(), map()) :: {:ok} | error
  @spec create_followup_message(User.id(), Interaction.token(), map()) :: {:ok} | error
  def create_followup_message(application_id \\ Bot.get().id, token, webhook_payload) do
    execute_webhook(application_id, token, webhook_payload)
  end

  @doc """
  Delete a followup message for an interaction.

  ## Parameters
  - `application_id`: Application ID for which to create the command.
    If not given, this will be fetched from `Me`.
  - `token`: Interaction token.
  - `message_id`: Followup message ID.
  """

  @spec delete_interaction_followup_message(Interaction.token(), Message.id()) :: {:ok} | error
  @spec delete_interaction_followup_message(User.id(), Interaction.token(), Message.id()) ::
          {:ok} | error
  def delete_interaction_followup_message(
        application_id \\ Bot.get().id,
        token,
        message_id
      ) do
    request(:delete, Endpoints.interaction_followup_message(application_id, token, message_id))
  end

  @spec maybe_add_reason(String.t() | nil) :: list()
  defp maybe_add_reason(reason) do
    maybe_add_reason(reason, [{"content-type", "application/json"}])
  end

  @spec maybe_add_reason(String.t() | nil, list()) :: list()
  defp maybe_add_reason(nil, headers) do
    headers
  end

  defp maybe_add_reason(reason, headers) do
    [{"x-audit-log-reason", reason} | headers]
  end

  def request(request) do
    GenServer.call(Ratelimiter, {:queue, request, nil}, :infinity)
  end

  # HTTPosion defaults to `""` for an empty body, so it's safe to do so here
  def request(method, route, body \\ "", options \\ []) do
    request = %{
      method: method,
      route: route,
      body: body,
      options: options,
      headers: [{"content-type", "application/json"}]
    }

    GenServer.call(Ratelimiter, {:queue, request, nil}, :infinity)
  end

  def request_multipart(method, route, body, options \\ []) do
    request = %{
      method: method,
      route: route,
      body:
        {:multipart,
         [
           {
             :file,
             body.file,
             {"form-data", [{"filename", body.content}]},
             [{"tts", body.tts}]
           }
         ]},
      options: options,
      headers: [{"content-type", "multipart/form-data"}]
    }

    GenServer.call(Ratelimiter, {:queue, request, nil}, :infinity)
  end

  @doc false
  def bangify(to_bang) do
    case to_bang do
      {:error, error} ->
        raise(error)

      {:ok, body} ->
        body

      {:ok} ->
        {:ok}
    end
  end

  @doc """
  Returns the token of the bot.
  """

  @spec get_token() :: String.t()
  def get_token do
    Application.get_env(:remedy, :token)
  end

  defp handle_request_with_decode(response)
  defp handle_request_with_decode({:ok, body}), do: {:ok, Poison.decode!(body, keys: :atoms)}
  defp handle_request_with_decode({:error, _} = error), do: error

  defp handle_request_with_decode(response, type)
  defp handle_request_with_decode({:ok}, _type), do: {:ok}
  defp handle_request_with_decode({:error, _} = error, _type), do: error

  defp handle_request_with_decode({:ok, body}, _type) do
    convert =
      body
      |> Poison.decode!(keys: :atoms)

    # |> Util.cast(type)

    {:ok, convert}
  end

  defp prepare_allowed_mentions(options) do
    with raw_options when raw_options != :all <- Map.get(options, :allowed_mentions, :all),
         allowed_mentions when is_map(allowed_mentions) <- parse_allowed_mentions(raw_options) do
      Map.put(options, :allowed_mentions, allowed_mentions)
    else
      _ ->
        Map.delete(options, :allowed_mentions)
    end
  end

  defp parse_allowed_mentions(:none), do: %{parse: []}
  defp parse_allowed_mentions(:everyone), do: %{parse: [:everyone]}

  # Parse users
  defp parse_allowed_mentions(:users), do: %{parse: [:users]}
  defp parse_allowed_mentions({:users, users}) when is_list(users), do: %{users: users}

  # Parse roles
  defp parse_allowed_mentions(:roles), do: %{parse: [:roles]}
  defp parse_allowed_mentions({:roles, roles}) when is_list(roles), do: %{roles: roles}

  # Parse many
  defp parse_allowed_mentions(options) when is_list(options) or is_map(options) do
    options
    |> Enum.map(&parse_allowed_mentions/1)
    |> Enum.reduce(fn a, b ->
      Map.merge(a, b, fn
        key, parse_a, parse_b when key in [:parse, :users, :roles] ->
          Enum.uniq(parse_a ++ parse_b)

        _k, _v1, v2 ->
          v2
      end)
    end)
    |> Map.put_new(:parse, [])
  end

  # ignore
  defp parse_allowed_mentions(options), do: options
end
