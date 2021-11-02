defmodule Remedy.Gateway.Dispatch.GuildEmojisUpdate do
  @moduledoc """
  Guild Emojis Update Event

  ## Payload

  `%Remedy.Schema.Guild{}`

  """

  require Logger
  alias Remedy.{Cache, Util}
  alias Ecto.Changeset

  def handle({event, %{guild_id: guild_id, emojis: emojis} = payload, socket}) do
    with {:ok, _changeset} <- validate_payload(payload),
         {:ok, guild} <- Cache.update_guild_emojis(guild_id, %{emojis: emojis}) do
      {event, guild, socket}
    else
      {:error, _changeset} ->
        Util.log_malformed(event)
    end
  end

  defp validate_payload(%{emojis: emojis, guild_id: guild_id}) do
    {%{}, %{id: :id, emojis: {:array, Emoji}}}
    |> Changeset.cast(%{id: guild_id, emojis: emojis}, [:emojis, :id])
    |> case do
      %Ecto.Changeset{valid?: true} = changeset -> {:ok, changeset}
      %Ecto.Changeset{valid?: false} = changeset -> {:error, changeset}
    end
  end
end
