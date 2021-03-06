defmodule Remedy.CastHelpers do
  @moduledoc """
  Functions for helping with struct casting etc.
  """

  @doc """
  Deep blast a term

  1. All structs will be converted to maps
  2. All tuples will be converted to lists

  """

  def deep_destructor(item) when is_map(item) do
    if(is_struct(item), do: Map.from_struct(item), else: item)
    |> Enum.reduce(%{}, fn
      {k, v}, acc when is_map(v) -> Map.put_new(acc, k, deep_destructor(v))
      {k, v}, acc when is_list(v) -> Map.put_new(acc, k, inner_list_destructor(v))
      {k, v}, acc when is_tuple(v) -> Map.put_new(acc, k, Tuple.to_list(v) |> inner_list_destructor())
      {k, v}, acc when is_integer(v) when is_binary(v) -> Map.put_new(acc, k, v)
      {k, v}, acc when is_nil(v) -> Map.put_new(acc, k, v)
      _, acc -> acc
    end)
  end

  defp inner_list_destructor(item) when is_list(item) do
    Enum.reduce(item, [], fn
      v, acc when is_map(v) -> [deep_destructor(v) | acc]
      v, acc when is_list(v) -> [inner_list_destructor(v) | acc]
      v, acc when is_tuple(v) -> [Tuple.to_list(v) |> inner_list_destructor() | acc]
      v, acc when is_integer(v) when is_binary(v) -> [v | acc]
      v, acc when is_nil(v) -> [v | acc]
    end)
    |> Enum.reverse()
  end

  @doc """
  Replacement for `stringimorphiform`

  """
  @spec deep_string_key(map) :: map
  def deep_string_key(item) when is_struct(item) do
    item
    |> Map.from_struct()
    |> deep_string_key()
  end

  def deep_string_key(item) when is_map(item) do
    Enum.reduce(item, %{}, fn
      {k, v}, acc when is_struct(v) -> Map.put_new(acc, to_string(k), v)
      {k, v}, acc when is_map(v) -> Map.put_new(acc, to_string(k), deep_string_key(v))
      {k, v}, acc when is_list(v) -> Map.put_new(acc, to_string(k), list_item(v))
      {k, v}, acc -> Map.put_new(acc, to_string(k), v)
    end)
  end

  def deep_string_key(item) when is_list(item), do: for(k <- item, into: [], do: deep_string_key(k))

  defp list_item(item) when is_struct(item), do: deep_string_key(item)
  defp list_item(item) when is_map(item), do: deep_string_key(item)
  defp list_item(item) when is_list(item), do: for(k <- item, into: [], do: list_item(k))
  defp list_item(item), do: item

  @spec deep_compactor(map) :: map
  @spec deep_compactor(list) :: list
  def deep_compactor(map) when is_map(map) do
    Enum.reduce(map, %{}, fn
      {k, v}, acc when is_struct(v) -> Map.put_new(acc, k, v)
      {_k, v}, acc when is_map(v) and map_size(v) == 0 -> acc
      {k, v}, acc when is_map(v) or is_list(v) -> Map.put_new(acc, k, deep_compactor(v))
      {_k, v}, acc when is_nil(v) -> acc
      {k, v}, acc when is_binary(v) when is_integer(v) -> Map.put_new(acc, k, v)
    end)
  end

  @doc """
  Replacement for `compactiform`
  """
  def deep_compactor(list) when is_list(list) do
    list
    |> Enum.reduce([], fn
      elem, acc ->
        cond do
          is_list(elem) and Enum.empty?(elem) -> acc
          is_list(elem) or is_map(elem) -> acc ++ [deep_compactor(elem)]
          is_nil(elem) -> acc
          true -> acc ++ [elem]
        end
    end)
  end
end
