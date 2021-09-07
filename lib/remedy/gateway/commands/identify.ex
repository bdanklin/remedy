defmodule Remedy.Gateway.Commands.Identify do
  @moduledoc """
  Identify
  """
  alias Remedy.Gateway.Intents
  alias Remedy.Util
  use Remedy.Schema, :payload

  @default_compress false
  @default_large_threshold 50
  @default_properties %{
    "$os" => to_string(elem(:os.type(), 0)),
    "$device" => "Remedy",
    "$browser" => "Remedy"
  }

  @defaults %{
    intents: Intents.get(),
    properties: @default_properties,
    compress: @default_compress,
    large_threshold: @default_large_threshold
  }

  @env %{
    compress: Application.compile_env(:remedy, :compress) || @default_compress,
    token: Application.compile_env(:remedy, :token),
    large_threshold: Application.compile_env(:remedy, :large_threshold) || @default_large_threshold
  }

  @primary_key false
  embedded_schema do
    field :token, :string
    field :properties, :map
    field :compress, :boolean, default: false
    field :large_threshold, :integer
    field :shard, {:array, :integer}
    field :intents, :integer
  end

  def payload(state, opts \\ [])

  def payload(%WSState{shard_num: shard_num}, opts) do
    [
      {:compress, opts[:compress]},
      {:large_threshold, opts[:large_threshold]},
      {:shard, [shard_num, Util.num_shards()]}
    ]
    |> Enum.into(@defaults)
    |> Map.merge(@env)
    |> build_payload()
  end

  def payload(term, _opts),
    do: raise("Expected a Websocket State, got: #{term}, Seppuku 切腹 ( ͡ಠ ʖ̯ ͡ಠ)")
end
