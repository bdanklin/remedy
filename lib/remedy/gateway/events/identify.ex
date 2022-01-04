defmodule Remedy.Gateway.Events.Identify do
  @moduledoc false
  use Remedy.Gateway.Payload
  import Remedy, only: [token: 0, shards: 0, intents: 0, system_architecture: 0]

  def payload(%WSState{shard: shard} = socket, _opts) do
    {%{
       token: token(),
       properties: %{
         "$os" => system_architecture(),
         "$browser" => "Remedy",
         "$device" => "Remedy"
       },
       compress: true,
       large_threshold: 250,
       shard: [shard, shards()],
       intents: intents()
     }, socket}
  end
end
