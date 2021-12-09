defmodule Remedy.Gateway.EventCache do
  @moduledoc false

  ## Internal function

  import Ecto.Query, warn: false

  alias Sunbake.Snowflake
  alias Remedy.Repo
  alias Ecto.Changeset

  alias Remedy.Schema.{
    Ban,
    Channel,
    Emoji,
    Guild,
    Integration,
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

  @doc false
  @spec delete_channel(snowflake) :: {:ok, Channel.t()} | {:error, changeset}
  def delete_channel(id), do: %Channel{id: id} |> Repo.delete()

  @doc false
  @spec update_channel(attrs) :: {:ok, Channel.t()} | {:error, changeset}
  def update_channel(%{id: id} = attrs), do: update_channel(id, attrs)

  @doc false
  @spec update_channel(snowflake, attrs) :: {:ok, Channel.t()} | {:error, changeset}
  def update_channel(id, attrs) do
    case Repo.get(Channel, id) do
      nil -> Channel.changeset(attrs) |> Repo.insert()
      %Channel{} = channel -> Channel.changeset(channel, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec delete_thread(snowflake) :: {:ok, Thread.t()} | {:error, changeset}
  def delete_thread(id), do: Repo.get(Thread, id) |> Repo.delete()

  @doc false
  @spec update_thread(attrs) :: {:ok, Thread.t()} | {:error, changeset}
  def update_thread(%{id: id} = attrs), do: update_thread(id, attrs)
  @doc false
  @spec update_thread(snowflake, attrs) :: {:ok, Thread.t()} | {:error, changeset}
  def update_thread(id, attrs) do
    case Repo.get(Thread, id) do
      nil ->
        Thread.changeset(attrs) |> Repo.insert()

      %Thread{} = thread ->
        Thread.changeset(thread, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec delete_ban(snowflake, snowflake) :: {:ok, Ban.t()} | {:error, changeset}
  def delete_ban(guild_id, user_id), do: Repo.get_by(Ban, %{guild_id: guild_id, user_id: user_id}) |> Repo.delete()

  @doc false
  @spec update_ban(attrs) :: {:ok, Ban.t()} | {:error, changeset}
  def update_ban(%{guild_id: guild_id, user_id: user_id} = attrs),
    do: Repo.get_by(Ban, %{guild_id: guild_id, user_id: user_id}) |> Ban.changeset(attrs) |> Repo.update()

  def delete_user(id) do
    Repo.get(User, id) |> Repo.delete()
  end

  @spec update_user(%{:id => any, optional(:__struct__) => none, optional(atom | binary) => any}) :: any
  def update_user(%{id: user_id} = attrs) do
    case Repo.get(User, user_id) do
      nil -> User.changeset(attrs) |> Repo.insert()
      %User{} = user -> User.changeset(user, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec update_presence(attrs) :: {:ok, User.t()} | {:error, changeset}
  def update_presence(%{user: user} = presence) do
    user |> Map.put_new(:presence, presence) |> update_user()
  end

  @doc false
  @spec update_member(attrs) :: {:ok, Member.t()} | {:error, changeset}
  def update_member(%{guild_id: guild_id, user_id: user_id} = attrs) do
    case Repo.get_by(Member, %{guild_id: guild_id, user_id: user_id}) do
      nil -> Member.changeset(attrs) |> Repo.insert()
      %Member{} = member -> member |> Member.changeset(attrs) |> Repo.update()
    end
  end

  @doc false
  def update_member(%{guild_id: _guild_id, user: %{id: user_id}} = attrs) do
    Map.put_new(attrs, :user_id, user_id) |> update_member()
  end

  @doc false
  @spec delete_guild(snowflake) :: {:ok, Guild.t()} | {:error, changeset}
  def delete_guild(guild_id), do: %Guild{id: guild_id} |> Repo.delete()

  @doc false
  @spec update_guild(attrs) :: any
  def update_guild(%{id: id} = attrs) do
    case Repo.get(Guild, id) do
      nil -> Guild.changeset(attrs) |> Repo.insert()
      %Guild{} = guild -> Guild.changeset(guild, attrs) |> Repo.update()
    end
  end

  @spec update_guild_emojis(attrs) :: any
  def update_guild_emojis(%{id: id} = attrs) do
    case Repo.get(Guild, id) do
      nil -> Guild.update_emojis_changeset(attrs) |> Repo.insert()
      %Guild{} = guild -> Guild.update_emojis_changeset(guild, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec delete_integration(snowflake) :: {:ok, Integration.t()} | {:error, changeset}
  def delete_integration(integration_id), do: %Integration{id: integration_id} |> Repo.delete()

  @doc false
  @spec update_integration(attrs) :: {:ok, Integration.t()} | {:error, changeset}
  def update_integration(%{id: integration_id} = attrs) do
    case Repo.get(Integration, integration_id) do
      nil -> Integration.changeset(attrs) |> Repo.insert()
      %Integration{} = integration -> Integration.changeset(integration, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec delete_invite(snowflake) :: {:ok, Invite.t()} | {:error, changeset}
  def delete_invite(invite_id), do: Repo.delete(%Invite{code: invite_id})

  @doc false
  @spec delete_invite(attrs) :: {:ok, Invite.t()} | {:error, changeset}
  def update_invite(%{id: id} = attrs) do
    case Repo.get(Invite, id) do
      nil -> Invite.changeset(attrs) |> Repo.insert()
      %Invite{} = invite -> Invite.changeset(invite, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec delete_message(snowflake) :: {:ok, Message.t()} | {:error, changeset}
  def delete_message(message_id) do
    %Message{id: message_id} |> Repo.delete()
  end

  @doc false
  @spec delete_message(attrs) :: {:ok, Message.t()} | {:error, changeset}
  def update_message(%{id: id} = attrs) do
    case Repo.get(Message, id) do
      nil -> Message.changeset(attrs) |> Repo.insert()
      %Message{} = message -> Message.changeset(message, attrs) |> Repo.update()
    end
  end

  @spec remove_message_reactions(snowflake) :: {:ok, Message.t()} | {:error, reason}
  def remove_message_reactions(message_id) do
    Repo.get(Message, message_id) |> Message.changeset(%{reactions: []}) |> Repo.update()
  end

  @doc false
  @spec delete_emoji(snowflake) :: {:ok, Emoji.t()} | {:error, changeset}
  def delete_emoji(emoji_id), do: Repo.get(Emoji, emoji_id) |> Repo.delete()

  @doc false
  @spec update_emoji(attrs) :: {:ok, Emoji.t()} | {:error, changeset}
  def update_emoji(%{id: id} = attrs) do
    case Repo.get(Emoji, id) do
      nil -> Emoji.changeset(attrs) |> Repo.insert()
      %Emoji{} = emoji -> Emoji.changeset(emoji, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec delete_role(snowflake) :: {:ok, Role.t()} | {:error, changeset}
  def delete_role(id), do: Repo.delete(%Role{id: id})

  @doc false
  @spec update_role(attrs) :: {:ok, Role.t()} | {:error, changeset}
  def update_role(%{id: role_id} = attrs) do
    case Repo.get(Role, role_id) do
      nil -> Role.changeset(attrs) |> Repo.insert()
      %Role{} = role -> Role.changeset(role, attrs) |> Repo.update()
    end
  end

  alias Ecto.Association.NotLoaded

  def drop_unloaded_assoc(%{} = map), do: drop_by(map, fn _, val -> val in [%NotLoaded{}] end)
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
end
