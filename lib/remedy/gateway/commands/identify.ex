defmodule Remedy.Gateway.Commands.Identify do
  @moduledoc false
  #############################################################################
  ## 2
  ## Identify
  ## Send
  ## Starts a new session during the initial handshake.

  use Remedy.Schema
  alias Remedy.Gateway.Session.WSState

  embedded_schema do
    field :token, :string

    field :properties, :map,
      default: %{
        "$os" => "#{:erlang.system_info(:system_architecture)}",
        "$browser" => "Remedy",
        "$device" => "Remedy"
      }

    field :compress, :boolean, default: true
    field :large_threshold, :integer, default: 250
    field :shard, {:array, :integer}, default: []
    field :intents, Intents
    embeds_one :presence, Remedy.Gateway.Commands.PresenceUpdate
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [])
  end

  def send(%WSState{shard: shard, shards: shards, token: token, intents: intents}, opts) do
    payload = %{
      token: token,
      shard: [shard, shards],
      intents: intents
    }

    attrs =
      opts
      |> Enum.into(%{})
      |> Map.merge(payload)

    %__MODULE__{}
    |> struct(opts)
  end
end
