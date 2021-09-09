defmodule Remedy.Gateway.Commands.UpdatePresence do
  @moduledoc false
  use Remedy.Schema, :payload

  embedded_schema do
    field :since, :string
    field :status, :string
    field :afk, :boolean
    embeds_one :activity, Activity
  end

  @defaults %{
    since: 91_879_201,
    status: "online",
    afk: false
  }

  def payload(socket, opts \\ [])

  def payload(socket, opts) do
    opts
    |> Enum.into(@defaults)
    |> build_payload(socket)
  end
end
