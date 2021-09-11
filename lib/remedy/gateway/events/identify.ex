defmodule Remedy.Gateway.Events.Identify do
  @moduledoc false

  alias Remedy.Gateway.Intents
  use Remedy.Gateway.Payload

  @large_threshold 50

  def send(%Websocket{shard: shard} = socket, _opts) do
    %{
      "token" => Application.get_env(:remedy, :token),
      "properties" => %{
        "$os" => to_string(:erlang.system_info(:system_architecture)),
        "$browser" => "Remedy",
        "$device" => "Remedy",
        "$referrer" => "",
        "$referring_domain" => ""
      },
      "compress" => true,
      "large_threshold" => @large_threshold,
      "shard" => [shard, Util.num_shards()],
      "intents" => Intents.get()
    }
  end
end
