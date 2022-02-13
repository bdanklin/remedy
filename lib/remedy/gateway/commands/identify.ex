defmodule Remedy.Gateway.Commands.Identify do
  @moduledoc false
  import Remedy, only: [intents: 0, system_architecture: 0]
  alias Remedy.Gateway.Session.WSState

  defstruct token: "",
            properties: %{
              "$os" => system_architecture(),
              "$browser" => "Remedy",
              "$device" => "Remedy"
            },
            compress: true,
            large_threshold: 250,
            shard: [],
            intents: 0

  def send(%WSState{shard: shard, shards: shards, token: token}, opts) do
    payload = %{
      token: token,
      shard: [shard, shards],
      intents: intents()
    }

    opts =
      %{large_threshold: opts[:large_threshold], compress: opts[:compress]}
      |> Enum.reject(fn x -> x == nil end)
      |> Enum.into(%{})
      |> Map.merge(payload)

    %__MODULE__{}
    |> struct(opts)
  end
end
