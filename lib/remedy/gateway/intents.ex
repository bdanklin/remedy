defmodule Remedy.Gateway.Intents do
  @moduledoc false
  use Remedy.Flag

  defstruct GUILDS: 1 <<< 0,
            GUILD_MEMBERS: 1 <<< 1,
            GUILD_BANS: 1 <<< 2,
            GUILD_EMOJIS_AND_STICKERS: 1 <<< 3,
            GUILD_INTEGRATIONS: 1 <<< 4,
            GUILD_WEBHOOKS: 1 <<< 5,
            GUILD_INVITES: 1 <<< 6,
            GUILD_VOICE_STATES: 1 <<< 7,
            GUILD_PRESENCES: 1 <<< 8,
            GUILD_MESSAGES: 1 <<< 9,
            GUILD_MESSAGE_REACTIONS: 1 <<< 10,
            GUILD_MESSAGE_TYPING: 1 <<< 11,
            DIRECT_MESSAGES: 1 <<< 12,
            DIRECT_MESSAGE_REACTIONS: 1 <<< 13,
            DIRECT_MESSAGE_TYPING: 1 <<< 14,
            GUILD_SCHEDULED_EVENTS: 1 <<< 15

  @doc false
  def get_config do
    Application.get_env(:remedy, :gateway_intents)
    |> resolve()
    |> to_integer()
  end

  defp resolve(:all) do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.keys()
  end

  defp resolve(value) when is_number(value) do
    value
  end

  defp resolve(list_of_intents) when is_list(list_of_intents) do
    %__MODULE__{}
    |> Map.from_struct()
    |> Map.to_list()
    |> Enum.filter(fn
      {k, _v} -> k in list_of_intents
    end)
    |> Enum.reduce([], fn
      {k, _v}, acc -> acc ++ [k]
    end)
  end
end
