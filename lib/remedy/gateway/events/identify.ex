defmodule Remedy.Gateway.Events.Identify do
  @moduledoc false

  alias Remedy.Gateway
  alias Remedy.Gateway.Intents
  use Remedy.Gateway.Payload

  def payload(%WSState{shard: shard} = socket, _opts) do
    {%{
       token: Application.get_env(:remedy, :token),
       properties: %{
         "$os" => "#{to_string(:erlang.system_info(:system_architecture))}",
         "$browser" => "Remedy",
         "$device" => "Remedy"
       },
       compress: true,
       large_threshold: 250,
       shard: [shard, Gateway.shard_count()],
       intents: Intents.get_config()
     }, socket}
  end
end
