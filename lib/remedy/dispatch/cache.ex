defmodule Remedy.Dispatch.Cache do
  @moduledoc false
  ##############################################################################
  ## Internal functions for updating the cache from Dispatch events.
  ##
  ##

  import Ecto.Query, warn: false
  alias Remedy.Repo

  alias Remedy.Snowflake
  alias Ecto.Changeset

  alias Remedy.Dispatch.Cache.Channel
  alias Remedy.Dispatch.Cache.Thread
  alias Remedy.Dispatch.Cache.Guild
  alias Remedy.Dispatch.Cache.Invite
  alias Remedy.Dispatch.Cache.Presence
  alias Remedy.Dispatch.Cache.Stage
  alias Remedy.Dispatch.Cache.User
  alias Remedy.Dispatch.Cache.VoiceRegion
  alias Remedy.Dispatch.Cache.VoiceState
  alias Remedy.Schema.Ban
  alias Remedy.Schema.Thread
  alias Remedy.Schema.User
  alias Remedy.Schema.Member
  alias Remedy.Schema.Guild
  alias Remedy.Schema.Integration
  alias Remedy.Schema.Message
  alias Remedy.Schema.Emoji
  alias Remedy.Schema.Role

  def delete_channel(id) do
    %Channel{id: id}
    |> Repo.delete()
  end

  def update_channel(%{id: id} = attrs) do
    update_channel(id, attrs)
  end

  def update_channel(id, attrs) do
    case Repo.get(Channel, id) do
      nil ->
        Channel.changeset(attrs)
        |> Repo.insert()

      %Channel{} = channel ->
        Channel.changeset(channel, attrs)
        |> Repo.update()
    end
  end

  def delete_thread(id) do
    %Thread{id: id}
    |> Repo.delete()
  end

  def update_thread(%{id: id} = attrs) do
    update_thread(id, attrs)
  end

  def update_thread(id, attrs) do
    case Repo.get(Thread, id) do
      nil ->
        Thread.changeset(attrs)
        |> Repo.insert()

      %Thread{} = thread ->
        Thread.changeset(thread, attrs)
        |> Repo.update()
    end
  end

  def delete_ban(guild_id, user_id) do
    Ban
    |> Repo.get_by(%{guild_id: guild_id, user_id: user_id})
    |> Repo.delete()
  end

  def update_ban(%{guild_id: guild_id, user_id: user_id} = attrs),
    do: Repo.get_by(Ban, %{guild_id: guild_id, user_id: user_id}) |> Ban.changeset(attrs) |> Repo.update()

  def delete_user(id) do
    Repo.get(User, id) |> Repo.delete()
  end

  def update_user(%{id: user_id} = attrs) do
    case Repo.get(User, user_id) do
      nil -> User.changeset(attrs) |> Repo.insert()
      %User{} = user -> User.changeset(user, attrs) |> Repo.update()
    end
  end

  def update_presence(%{user: user} = presence) do
    user |> Map.put_new(:presence, presence) |> update_user()
  end

  def update_member(%{guild_id: guild_id, user_id: user_id} = attrs) do
    case Repo.get_by(Member, %{guild_id: guild_id, user_id: user_id}) do
      nil -> Member.changeset(attrs) |> Repo.insert()
      %Member{} = member -> member |> Member.changeset(attrs) |> Repo.update()
    end
  end

  def update_member(%{guild_id: _guild_id, user: %{id: user_id}} = attrs) do
    Map.put_new(attrs, :user_id, user_id) |> update_member()
  end

  def delete_guild(guild_id), do: %Guild{id: guild_id} |> Repo.delete()

  def update_guild(%{id: id} = attrs) do
    case Repo.get(Guild, id) do
      nil -> Guild.changeset(attrs) |> Repo.insert()
      %Guild{} = guild -> Guild.changeset(guild, attrs) |> Repo.update()
    end
  end

  def update_guild_emojis(%{id: id} = attrs) do
    case Repo.get(Guild, id) do
      nil -> Guild.update_emojis_changeset(attrs) |> Repo.insert()
      %Guild{} = guild -> Guild.update_emojis_changeset(guild, attrs) |> Repo.update()
    end
  end

  def delete_integration(integration_id), do: %Integration{id: integration_id} |> Repo.delete()

  def update_integration(%{id: integration_id} = attrs) do
    case Repo.get(Integration, integration_id) do
      nil -> Integration.changeset(attrs) |> Repo.insert()
      %Integration{} = integration -> Integration.changeset(integration, attrs) |> Repo.update()
    end
  end

  @doc false
  def delete_invite(invite_id), do: Repo.delete(%Invite{code: invite_id})

  def update_invite(%{id: id} = attrs) do
    case Repo.get(Invite, id) do
      nil -> Invite.changeset(attrs) |> Repo.insert()
      %Invite{} = invite -> Invite.changeset(invite, attrs) |> Repo.update()
    end
  end

  def delete_message(message_id) do
    %Message{id: message_id} |> Repo.delete()
  end

  def update_message(%{id: id} = attrs) do
    case Repo.get(Message, id) do
      nil -> Message.changeset(attrs) |> Repo.insert()
      %Message{} = message -> Message.changeset(message, attrs) |> Repo.update()
    end
  end

  def remove_message_reactions(message_id) do
    Repo.get(Message, message_id) |> Message.changeset(%{reactions: []}) |> Repo.update()
  end

  def delete_emoji(emoji_id), do: Repo.get(Emoji, emoji_id) |> Repo.delete()

  def update_emoji(%{id: id} = attrs) do
    case Repo.get(Emoji, id) do
      nil -> Emoji.changeset(attrs) |> Repo.insert()
      %Emoji{} = emoji -> Emoji.changeset(emoji, attrs) |> Repo.update()
    end
  end

  def delete_role(id), do: Repo.delete(%Role{id: id})

  def update_role(%{id: role_id} = attrs) do
    case Repo.get(Role, role_id) do
      nil -> Role.changeset(attrs) |> Repo.insert()
      %Role{} = role -> Role.changeset(role, attrs) |> Repo.update()
    end
  end
end
