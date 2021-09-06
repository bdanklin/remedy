defmodule Remedy.Gateway.Commands.UpdatePresence do
  @moduledoc false
  use Remedy.Schema, :payload

  embedded_schema do
    field :since, :string
    field :status, :string
    field :afk, :boolean
    embeds_one :activity, Activity
  end

  def payload(state, opts \\ [])

  def payload(%WSState{}, opts) do
    %{
      since: opts[:since],
      status: opts[:status],
      afk: opts[:afk]
    }
    |> build_payload()
  end

  def validate(changeset) do
    changeset
  end
end
