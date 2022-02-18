defmodule Remedy.CastHelpers do
  @moduledoc """
  Functions for helping with struct casting etc.
  """

  @doc """
  Blast a term to prepare for sending over websocket.

  1. All structs will be converted to maps
  2. All keys for Maps or Structs will be converted to strings.
  """

  def deep_struct_blaster(item) when is_struct(item), do: Map.from_struct(item) |> deep_struct_blaster()
  def deep_struct_blaster(item) when is_map(item), do: for({k, v} <- item, into: %{}, do: {k, deep_struct_blaster(v)})
  def deep_struct_blaster(item) when is_list(item), do: for(k <- item, into: [], do: deep_struct_blaster(k))
  def deep_struct_blaster(item), do: item

  def deep_string_key(item) when is_struct(item), do: Map.from_struct(item)

  def deep_string_key(item) when is_map(item) do
    Enum.reduce(item, %{}, fn
      {k, v}, acc when is_struct(v) -> Map.put_new(acc, to_string(k), v)
      {k, v}, acc when is_map(v) -> Map.put_new(acc, to_string(k), deep_string_key(v))
      {k, v}, acc when is_list(v) -> Map.put_new(acc, to_string(k), list_item(v))
      {k, v}, acc -> Map.put_new(acc, to_string(k), v)
    end)
  end

  def deep_string_key(item) when is_list(item), do: for(k <- item, into: [], do: deep_string_key(k))

  defp list_item(item) when is_struct(item), do: &deep_string_key/1
  defp list_item(item) when is_map(item), do: &deep_string_key/1
  defp list_item(item) when is_list(item), do: for(k <- item, into: [], do: list_item(k))
  defp list_item(item), do: item
end
