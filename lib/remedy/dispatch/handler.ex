defmodule Remedy.Dispatch.EventHandler do
  @moduledoc false

  alias Remedy.Dispatch.EventCache

  require Logger

  def handle({event, payload, socket}) do
    if Application.get_env(:remedy, :log_everything, true), do: nil
    #  do: Logger.debug("#{inspect(event)}, #{inspect(payload, pretty: true, limit: :infinity)}")
    #  do: Logger.debug("#{inspect(event)}")

    handle(event, payload, socket)
  end

  def handle(:CHANNEL_CREATE, payload, socket) do
    payload
    |> EventCache.update_channel()
    |> case do
      {:ok, channel} ->
        {:CHANNEL_CREATE, channel, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:CHANNEL_DELETE, %{id: id}, socket) do
    id
    |> EventCache.delete_channel()
    |> case do
      {:ok, channel} ->
        {:CHANNEL_DELETE, channel, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:CHANNEL_PINS_UPDATE, %{channel_id: id, last_pin_timestamp: last_pin_timestamp}, socket) do
    %{id: id, last_pin_timestamp: last_pin_timestamp}
    |> EventCache.update_channel()
    |> case do
      {:ok, channel} ->
        {:CHANNEL_PINS_UPDATE, channel, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:CHANNEL_UPDATE, payload, socket) do
    payload
    |> EventCache.update_channel()
    |> case do
      {:ok, channel} ->
        {:CHANNEL_UPDATE, channel, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:EMBEDDED_ACTIVITY_UPDATE, payload, socket) do
    {:EMBEDDED_ACTIVITY_UPDATE, payload, socket}
  end

  def handle(:GUILD_BAN_ADD, %{guild_id: guild_id, ban: %{user: %{id: user_id} = user, reason: reason}}, socket) do
    ban_params = %{user_id: user_id, guild_id: guild_id, reason: reason}

    EventCache.update_user(user)

    case EventCache.update_ban(ban_params) do
      {:ok, ban} ->
        {:GUILD_BAN_ADD, ban, socket}

      {:error, _reason} ->
        :noop
    end
  end

  def handle(:GUILD_BAN_REMOVE, %{guild_id: guild_id, ban: %{user: %{id: user_id} = user}}, socket) do
    EventCache.update_user(user)

    case EventCache.delete_ban(user_id, guild_id) do
      {:ok, ban} ->
        {:GUILD_BAN_REMOVE, ban, socket}

      _ ->
        :noop
    end
  end

  def handle(:GUILD_CREATE, %{id: guild_id} = payload, socket) do
    unless payload[:presences] == nil do
      for presence <- payload[:presences] do
        EventCache.update_presence(presence)
      end
    end

    unless payload[:channels] == nil do
      for channel <- payload[:channels] do
        Map.put_new(channel, :guild_id, guild_id)
        |> EventCache.update_channel()
      end
    end

    unless payload[:threads] == nil do
      for thread <- payload[:threads] do
        Map.put_new(thread, :guild_id, guild_id)
        |> EventCache.update_channel()
      end
    end

    unless payload[:members] == nil do
      for %{user: user} = member <- payload[:members] do
        EventCache.update_user(user)

        Map.put_new(member, :guild_id, guild_id)
        |> EventCache.update_member()
      end
    end

    unless payload[:emojis] == nil do
      for emoji <- payload[:emojis] do
        Map.put_new(emoji, :guild_id, guild_id)
        |> EventCache.update_emoji()
      end
    end

    unless payload[:roles] == nil do
      for role <- payload[:roles] do
        Map.put_new(role, :guild_id, guild_id)
        |> EventCache.update_role()
      end
    end

    payload
    |> Map.put_new(:shard, socket.shard)
    |> EventCache.update_guild()
    |> case do
      {:ok, guild} ->
        {:GUILD_CREATE, guild, socket}

      _ ->
        :noop
    end
  end

  def handle(:GUILD_DELETE, %{id: guild_id}, socket) do
    guild_id
    |> EventCache.delete_guild()
    |> case do
      {:ok, guild} ->
        {:GUILD_DELETE, guild, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:GUILD_EMOJIS_UPDATE, %{guild_id: guild_id} = payload, socket) do
    payload
    |> Map.delete(:guild_id)
    |> Map.put_new(:id, guild_id)
    |> EventCache.update_guild()
    |> case do
      {:ok, guild} ->
        {:GUILD_EMOJIS_UPDATE, guild, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:GUILD_INTEGRATIONS_UPDATE, payload, socket) do
    {:GUILD_INTEGRATIONS_UPDATE, payload, socket}
  end

  def handle(:GUILD_MEMBER_ADD, %{user: %{id: user_id} = user} = payload, socket) do
    EventCache.update_user(user)

    payload
    |> Map.put_new(:user_id, user_id)
    |> EventCache.update_member()
    |> case do
      {:ok, member} ->
        {:GUILD_MEMBER_ADD, member, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:GUILD_MEMBER_REMOVE, payload, socket) do
    {:GUILD_MEMBER_REMOVE, payload, socket}
  end

  def handle(:GUILD_MEMBER_UPDATE, %{user: %{id: user_id} = user} = payload, socket) do
    EventCache.update_user(user)

    payload
    |> Map.put_new(:user_id, user_id)
    |> EventCache.update_member()
    |> case do
      {:ok, member} ->
        {:GUILD_MEMBER_UPDATE, member, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:GUILD_MEMBER_CHUNK, payload, socket) do
    {:GUILD_MEMBER_CHUNK, payload, socket}
  end

  def handle(:GUILD_ROLE_CREATE, %{guild_id: guild_id, role: role}, socket) do
    role
    |> Map.put_new(:guild_id, guild_id)
    |> EventCache.update_role()
    |> case do
      {:ok, role} ->
        {:GUILD_ROLE_CREATE, role, socket}

      {:error, _reason} ->
        :noop
    end
  end

  def handle(:GUILD_ROLE_DELETE, %{role: %{id: role_id}}, socket) do
    role_id
    |> EventCache.delete_role()
    |> case do
      {:ok, role} ->
        {:GUILD_ROLE_DELETE, role, socket}

      {:error, _reason} ->
        :noop
    end
  end

  def handle(:GUILD_ROLE_UPDATE, %{guild_id: guild_id, role: role}, socket) do
    role
    |> Map.put_new(:guild_id, guild_id)
    |> EventCache.update_role()
    |> case do
      {:ok, role} ->
        {:GUILD_ROLE_UPDATE, role, socket}

      {:error, _reason} ->
        :noop
    end
  end

  def handle(:GUILD_STICKERS_UPDATE, %{id: guild_id, stickers: stickers} = _payload, socket) do
    case EventCache.update_guild(%{id: guild_id, stickers: stickers}) do
      {:ok, guild} ->
        {:GUILD_STICKERS_UPDATE, guild, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:GUILD_UPDATE, payload, socket) do
    payload
    |> Map.put_new(:shard, socket.shard)
    |> EventCache.update_guild()
    |> case do
      {:ok, guild} ->
        {:GUILD_UPDATE, guild, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:INTEGRATION_CREATE, payload, socket) do
    payload
    |> EventCache.update_integration()
    |> case do
      {:ok, integration} ->
        {:INTEGRATION_CREATE, integration, socket}

      {:error, _reason} ->
        :noop
    end
  end

  def handle(:INTEGRATION_DELETE, %{id: id}, socket) do
    EventCache.delete_integration(id)
    |> case do
      {:ok, integration} ->
        {:INTEGRATION_DELETE, integration, socket}

      {:error, _reason} ->
        :noop
    end
  end

  def handle(:INTEGRATION_UPDATE, payload, socket) do
    payload
    |> EventCache.update_integration()
    |> case do
      {:ok, integration} ->
        {:INTEGRATION_UPDATE, integration, socket}

      {:error, _reason} ->
        :noop
    end
  end

  def handle(:INTERACTION_CREATE, %{data: %{resolved: resolved}} = payload, socket) do
    payload =
      put_in(payload.data.resolved, for({k, v} <- resolved, into: %{}, do: {k, for({_k, v} <- v, into: [], do: v)}))
      |> form(Remedy.Schema.Interaction)

    {:INTERACTION_CREATE, payload, socket}
  end

  def handle(:INVITE_CREATE, payload, socket) do
    payload
    |> EventCache.update_invite()
    |> case do
      {:ok, invite} ->
        {:INVITE_CREATE, invite, socket}

      {:error, _reason} ->
        :noop
    end
  end

  def handle(:INVITE_DELETE, %{code: code}, socket) do
    code
    |> EventCache.delete_invite()
    |> case do
      {:ok, invite} ->
        {:INVITE_DELETE, invite, socket}

      {:error, _reason} ->
        :noop
    end
  end

  def handle(:MESSAGE_CREATE, payload, socket) do
    {:MESSAGE_CREATE, payload, socket}
  end

  def handle(:MESSAGE_DELETE, payload, socket) do
    {:MESSAGE_DELETE, payload, socket}
  end

  def handle(:MESSAGE_UPDATE, payload, socket) do
    {:MESSAGE_UPDATE, payload, socket}
  end

  def handle(:MESSAGE_DELETE_BULK, payload, socket) do
    {:MESSAGE_DELETE_BULK, payload, socket}
  end

  def handle(:MESSAGE_REACTION_ADD, payload, socket) do
    {:MESSAGE_REACTION_ADD, payload, socket}
  end

  def handle(:MESSAGE_REACTION_REMOVE_ALL, payload, socket) do
    {:MESSAGE_REACTION_REMOVE_ALL, payload, socket}
  end

  def handle(:MESSAGE_REACTION_REMOVE_EMOJI, payload, socket) do
    {:MESSAGE_REACTION_REMOVE_EMOJI, payload, socket}
  end

  def handle(:MESSAGE_REACTION_REMOVE, payload, socket) do
    {:MESSAGE_REACTION_REMOVE, payload, socket}
  end

  def handle(:PRESENCE_UPDATE, %{user: user} = payload, socket) do
    EventCache.update_user(user)
    EventCache.update_presence(payload)

    {:PRESENCE_UPDATE, payload, socket}
  end

  def handle(:READY, payload, socket) do
    {:READY, payload, socket}
  end

  def handle(:RESUMED, payload, socket) do
    {:RESUMED, payload, socket}
  end

  def handle(:SPEAKING_UPDATE, payload, socket) do
    {:SPEAKING_UPDATE, payload, socket}
  end

  def handle(:STAGE_INSTANCE_CREATE, payload, socket) do
    {:STAGE_INSTANCE_CREATE, payload, socket}
  end

  def handle(:STAGE_INSTANCE_DELETE, payload, socket) do
    {:STAGE_INSTANCE_DELETE, payload, socket}
  end

  def handle(:STAGE_INSTANCE_UPDATE, payload, socket) do
    {:STAGE_INSTANCE_UPDATE, payload, socket}
  end

  def handle(:THREAD_CREATE, payload, socket) do
    payload
    |> EventCache.update_thread()
    |> case do
      {:ok, channel} ->
        {:THREAD_CREATE, channel, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:THREAD_DELETE, %{id: id}, socket) do
    id
    |> EventCache.delete_thread()
    |> case do
      {:ok, channel} ->
        {:THREAD_DELETE, channel, socket}

      {:error, _changeset} ->
        :noop
    end
  end

  def handle(:THREAD_UPDATE, payload, socket) do
    {:THREAD_UPDATE, payload, socket}
  end

  def handle(:THREAD_LIST_SYNC, payload, socket) do
    {:THREAD_LIST_SYNC, payload, socket}
  end

  def handle(:THREAD_MEMBER_UPDATE, payload, socket) do
    {:THREAD_MEMBER_UPDATE, payload, socket}
  end

  def handle(:THREAD_MEMBERS_UPDATE, payload, socket) do
    {:THREAD_MEMBERS_UPDATE, payload, socket}
  end

  def handle(:TYPING_START, %{member: %{user: %{id: user_id} = user} = member, guild_id: guild_id} = payload, socket) do
    member
    |> Map.put_new(:guild_id, guild_id)
    |> Map.put_new(:user_id, user_id)
    |> EventCache.update_member()

    user
    |> EventCache.update_user()

    typing_start =
      %{payload | member: member}
      |> Map.put(:timestamp, DateTime.from_unix!(payload.timestamp))
      |> form(Remedy.Schema.TypingStart)

    {:TYPING_START, typing_start, socket}
  end

  def handle(:USER_UPDATE, payload, socket) do
    {:USER_UPDATE, payload, socket}
  end

  def handle(:VOICE_STATE_UPDATE, payload, socket) do
    {:VOICE_STATE_UPDATE, payload, socket}
  end

  def handle(:WEBHOOKS_UPDATE, payload, socket) do
    {:WEBHOOKS_UPDATE, payload, socket}
  end

  def handle(unhandled_event, payload, socket) do
    Logger.warn("UNHANDLED GATEWAY DISPATCH EVENT TYPE: #{unhandled_event}, #{inspect(payload)}")
    {unhandled_event, payload, socket}
  end

  defp form(attrs, module) do
    module.changeset(attrs) |> Ecto.Changeset.apply_changes()
  end
end
