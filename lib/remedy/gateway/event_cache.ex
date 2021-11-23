defmodule Remedy.Gateway.EventCache do
  import Ecto.Query, warn: false

  alias Sunbake.Snowflake
  alias Remedy.Cache.Repo
  alias Ecto.Changeset

  alias Remedy.Schema.{
    App,
    Ban,
    Channel,
    Emoji,
    Guild,
    Integration,
    Interaction,
    Invite,
    Member,
    Message,
    Role,
    Thread,
    User
  }

  @type snowflake :: Snowflake.t()
  @type reason :: String.t()
  @type attrs :: map()
  @type changeset :: Changeset.t()

  ###########
  ### Channels
  ###########

  # def update_thread_members

  @doc false
  @spec get_channel(snowflake) :: nil | Channel.t()
  def get_channel(id), do: Repo.get(Channel, id)

  @doc false
  @spec delete_channel(snowflake) :: {:ok, Channel.t()} | {:error, changeset}
  def delete_channel(id), do: get_channel(id) |> Repo.delete()

  @doc false
  @spec update_channel(attrs) :: {:ok, Channel.t()} | {:error, changeset}
  def update_channel(%{id: id} = attrs), do: update_channel(id, attrs)
  @doc false
  @spec update_channel(snowflake, attrs) :: {:ok, Channel.t()} | {:error, changeset}
  def update_channel(id, attrs) do
    case get_channel(id) do
      nil ->
        Channel.changeset(attrs) |> Repo.insert()

      %Channel{} = channel ->
        Channel.changeset(channel, attrs) |> Repo.update()
    end
  end

  ###########
  ### Threads
  ###########

  @doc false
  @spec get_thread(snowflake) :: nil | Thread.t()
  def get_thread(id), do: Repo.get(Thread, id)

  @doc false
  @spec delete_thread(snowflake) :: {:ok, Thread.t()} | {:error, changeset}
  def delete_thread(id), do: get_thread(id) |> Repo.delete()

  @doc false
  @spec update_thread(attrs) :: {:ok, Thread.t()} | {:error, changeset}
  def update_thread(%{id: id} = attrs), do: update_thread(id, attrs)
  @doc false
  @spec update_thread(snowflake, attrs) :: {:ok, Thread.t()} | {:error, changeset}
  def update_thread(id, attrs) do
    case get_thread(id) do
      nil ->
        Thread.changeset(attrs) |> Repo.insert()

      %Thread{} = thread ->
        Thread.changeset(thread, attrs) |> Repo.update()
    end
  end

  ###########
  ### Bans
  ###########

  @spec get_ban(snowflake, snowflake) :: nil | Ban.t()
  defp get_ban(guild_id, user_id), do: Repo.get_by(Ban, %{guild_id: guild_id, user_id: user_id})

  @doc false
  @spec delete_ban(snowflake, snowflake) :: {:ok, Ban.t()} | {:error, changeset}
  def delete_ban(guild_id, user_id), do: get_ban(guild_id, user_id) |> Repo.delete()

  @doc false
  @spec update_ban(attrs) :: {:ok, Ban.t()} | {:error, changeset}
  def update_ban(%{guild_id: guild_id, user_id: user_id} = attrs),
    do: get_ban(guild_id, user_id) |> Ban.changeset(attrs) |> Repo.update()

  ###########
  ### User
  ###########
  def update_user(attrs) do
    case get_user(attrs) do
      nil ->
        User.changeset(attrs)
        |> Repo.insert()

      %User{} = user ->
        User.changeset(user, attrs)
        |> Repo.update()
    end
  end

  @doc false
  def get_user(%{id: id}), do: Repo.get(User, id)
  def get_user(id), do: Repo.get(User, id)

  def delete_user(id) do
    User |> Repo.get(id) |> Repo.delete()
  end

  ###########
  ### Members
  ###########

  def get_member(guild_id, user_id), do: Repo.get_by(Member, %{guild_id: guild_id, user_id: user_id})

  def update_member(%{guild_id: guild_id, user_id: user_id} = attrs) do
    case get_member(guild_id, user_id) do
      nil -> Member.changeset(attrs) |> Repo.insert()
      %Member{} = member -> member |> Member.changeset(attrs) |> Repo.update()
    end
  end

  def update_member(%{guild_id: _guild_id, user: %{id: user_id}} = attrs) do
    Map.put_new(attrs, :user_id, user_id) |> update_member()
  end

  @doc false
  def update_presence(%{user: user} = presence), do: Map.put_new(user, :presence, presence) |> update_user()

  @doc false
  @spec update_guild(attrs) :: any
  def update_guild(%{id: id} = attrs) do
    case get_guild(id) do
      nil -> Guild.changeset(attrs) |> Repo.insert()
      %Guild{} = guild -> Guild.changeset(guild, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec get_guild(snowflake) :: nil | Guild.t()
  def get_guild(guild_id), do: Repo.get(Guild, guild_id)

  @doc false
  @spec delete_guild(snowflake) :: {:ok, Guild.t()} | {:error, changeset}
  def delete_guild(guild_id), do: get_guild(guild_id) |> Repo.delete()

  @doc false
  @spec get_integration(snowflake) :: nil | Integration.t()
  def get_integration(integration_id), do: Repo.get(Integration, integration_id)

  @doc false
  @spec delete_integration(snowflake) :: {:ok, Integration.t()} | {:error, changeset}
  def delete_integration(integration_id), do: get_integration(integration_id) |> Repo.delete()

  @doc false
  @spec update_integration(attrs) :: {:ok, Integration.t()} | {:error, changeset}
  def update_integration(%{id: integration_id} = attrs) do
    case get_integration(integration_id) do
      nil -> Integration.changeset(attrs) |> Repo.insert()
      %Integration{} = integration -> Integration.changeset(integration, attrs) |> Repo.update()
    end
  end

  #################
  #### Interactions
  #################

  def create_interaction(attrs) do
    attrs
    |> Interaction.changeset()
    |> Repo.insert()
  end

  ############
  #### Invites
  ############

  @doc false
  @spec get_invite(snowflake) :: nil | Invite.t()
  def get_invite(invite_id), do: Repo.get(Invite, invite_id)

  @doc false
  @spec delete_invite(snowflake) :: {:ok, Invite.t()} | {:error, changeset}
  def delete_invite(invite_id), do: get_invite(invite_id) |> Repo.delete()

  @doc false
  def update_invite(%{id: id} = attrs) do
    case Repo.get(Invite, id) do
      nil -> Invite.changeset(attrs) |> Repo.insert()
      %Invite{} = invite -> Invite.changeset(invite, attrs) |> Repo.update()
    end
  end

  #############
  #### Message
  #############

  @doc false
  def update_message(%{id: id} = attrs) do
    case Repo.get(Message, id) do
      nil -> Message.changeset(attrs) |> Repo.insert()
      %Message{} = message -> Message.changeset(message, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec get_message(snowflake) :: nil | Message.t()
  def get_message(message_id), do: Repo.get(Message, message_id)

  @doc false
  @spec delete_message(snowflake) :: {:ok, Message.t()} | {:error, changeset}
  def delete_message(message_id) do
    get_message(message_id) |> Repo.delete()
  end

  @doc false
  @spec update_message(snowflake, attrs) :: {:ok, Message.t()} | {:error, changeset}
  def update_message(message_id, attrs) do
    get_message(message_id) |> Message.changeset(attrs) |> Repo.update()
  end

  @spec remove_message_reactions(snowflake) :: {:ok, Message.t()} | {:error, reason}
  def remove_message_reactions(message_id) do
    get_message(message_id) |> Message.changeset(%{reactions: []}) |> Repo.update()
  end

  #########
  ### Emoji
  #########

  @doc false
  @spec get_emoji(snowflake) :: nil | Emoji.t()
  def get_emoji(emoji_id), do: Repo.get(Emoji, emoji_id)

  @doc false
  @spec delete_emoji(snowflake) :: {:ok, Emoji.t()} | {:error, changeset}
  def delete_emoji(emoji_id), do: get_emoji(emoji_id) |> Repo.delete()

  @doc false
  def update_emoji(%{id: id} = attrs) do
    case Repo.get(Emoji, id) do
      nil -> Emoji.changeset(attrs) |> Repo.insert()
      %Emoji{} = emoji -> Emoji.changeset(emoji, attrs) |> Repo.update()
    end
  end

  #########
  ### Roles
  #########

  @doc false
  @spec update_role(attrs) :: {:ok, Role.t()} | {:error, changeset}
  def update_role(%{id: role_id} = attrs) do
    case get_role(role_id) do
      nil -> Role.changeset(attrs) |> Repo.insert()
      %Role{} = role -> Role.changeset(role, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec get_role(snowflake) :: nil | Role.t()
  def get_role(id), do: Repo.get(Role, id)

  @doc false
  @spec delete_role(snowflake) :: {:ok, Role.t()} | {:error, changeset}
  def delete_role(id), do: get_role(id) |> Repo.delete()

  @doc false
  def init_bot(bot) do
    clear_bot_cache()

    User.system_changeset(bot)
    |> Repo.insert()
  end

  def bot, do: Repo.get_by(User, %{remedy_system: true})

  defp clear_bot_cache() do
    case bot() do
      %User{} = user -> Repo.delete(user)
      nil -> :noop
    end

    :ok
  end

  @doc false
  def init_app(app) do
    clear_app_cache()

    App.system_changeset(app)
    |> Repo.insert()
  end

  def app, do: Repo.get_by(App, %{remedy_system: true})

  defp clear_app_cache do
    case app() do
      %App{} = app -> Repo.delete(app)
      nil -> :noop
    end

    :ok
  end

  alias Ecto.Association.NotLoaded

  @spec drop_unloaded_assoc(map) :: any
  def drop_unloaded_assoc(%{} = map), do: drop_by(map, fn _, val -> val in [%NotLoaded{}] end)

  @spec drop_metadata(map) :: any
  def drop_metadata(%{} = map), do: drop_by(map, fn key, _ -> key in [:__meta__] end)

  defp drop_by(struct, _predicate) when is_struct(struct), do: struct
  defp drop_by(map, predicate) when is_map(map), do: clean_by(map, predicate)
  defp drop_by(list, predicate) when is_list(list), do: Enum.map(list, &drop_by(&1, predicate))
  defp drop_by(elem, _predicate), do: elem

  defp clean_by(map, predicate) do
    Enum.reduce(map, %{}, fn {key, val}, acc ->
      if predicate.(key, drop_by(val, predicate)) do
        acc
      else
        Map.put(acc, key, drop_by(val, predicate))
      end
    end)
  end

  defp wrap_list({:error, _reason} = error), do: error
  defp wrap_list([]), do: {:ok, []}
  defp wrap_list([_ | _] = list), do: {:ok, list}

  defp wrap(%{} = struct), do: {:ok, struct}
  defp wrap(nil), do: {:error, @not_found}

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise("Cache Error")
end
