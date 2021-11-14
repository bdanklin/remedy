defmodule Remedy.Gateway.Dispatch.GuildStickersUpdate do
  @moduledoc false
  require Logger
  alias Remedy.Cache
  alias Ecto.Changeset

  def handle({event, payload, socket}) do
    with {:ok, %{id: guild_id, stickers: stickers}} <- validate_payload(payload),
         {:ok, guild} <- Cache.update_guild_stickers(guild_id, %{stickers: stickers}) do
      {event, guild, socket}
    else
      {:error, _changeset} ->
        :noop
    end
  end

  defp validate_payload(%{stickers: stickers, guild_id: guild_id}) do
    {%{}, %{id: :id, stickers: {:array, Emoji}}}
    |> Changeset.cast(%{id: guild_id, stickers: stickers}, [:stickers, :id])
    |> case do
      %Ecto.Changeset{valid?: true} = changeset -> {:ok, changeset |> Changeset.apply_changes()}
      %Ecto.Changeset{valid?: false} = changeset -> {:error, changeset}
    end
  end
end
