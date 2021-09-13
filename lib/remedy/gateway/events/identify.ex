defmodule Remedy.Gateway.Events.Identify do
  @moduledoc false

  alias Remedy.Gateway.Intents
  use Remedy.Gateway.Payload

  def payload(%Websocket{shard: shard, token: token} = socket, _opts) do
    {%{
       "token" => token,
       "properties" => %{
         "$os" => to_string(:erlang.system_info(:system_architecture)),
         "$browser" => "Remedy",
         "$device" => "Remedy",
         "$referrer" => "",
         "$referring_domain" => ""
       },
       "compress" => true,
       "large_threshold" => 250,
       "shard" => [shard, Util.num_shards()],
       "intents" => Intents.get()
     }, socket}
  end
end