defmodule Remedy.Schema.Identify do
  @moduledoc false
  use Remedy.Schema

  @defaults %{
    "token" => Application.get_env(:remedy, :token),
    "properties" => %{
      "$os" => to_string(elem(:os.type(), 0)),
      "$device" => "Remedy",
      "$browser" => "Remedy"
    },
    "compress" => false,
    "large_threshold" => 50,
    "shard" => "",
    "intents" => ""
  }

  # these are the opts
  def payload(state, opts \\ []) do
    [
      {"compress", opts["compress"]},
      {"large_threshold", opts["large_threshold"]},
      {"shard"}
    ]
  end
end
