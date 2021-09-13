defmodule Remedy.Gateway.Events.Identify do
  @moduledoc false

  alias Remedy.Gateway.Intents
  alias Remedy.Gateway
  use Remedy.Gateway.Payload

  defp payload(%Websocket{shard: shard, token: token} = socket, _opts) do
    {%{
       token: token,
       properties: %{
         "$os" => "#{to_string(:erlang.system_info(:system_architecture))}",
         "$browser" => "Remedy",
         "$device" => "Remedy"
       },
       compress: true,
       large_threshold: 250,
       shard: [shard, Gateway.num_shards()],
       intents: Intents.get()
     }, socket}
  end
end
