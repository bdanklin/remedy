defmodule Remedy.CastHelpers do
  @moduledoc """
  Functions for helping with struct casting etc.
  """

  @doc """
  Deep blast a term

  1. All structs will be converted to maps
  2. All tuples will be converted to lists

  """

  def deep_blast(item) when is_struct(item) do
    item
    |> Map.from_struct()
    |> deep_blast()
  end

  def deep_blast(item) when is_map(item) do
    for {k, v} <- item, into: %{} do
      {k, deep_blast(v)}
    end
  end

  def deep_blast(item) when is_list(item) do
    for k <- item, into: [] do
      deep_blast(k)
    end
  end

  def deep_blast(item) when is_tuple(item) do
    item
    |> Tuple.to_list()
    |> deep_blast()
  end

  def deep_blast(item) when is_binary(item) when is_integer(item) do
    item
  end

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

  defp list_item(item) when is_struct(item), do: &deep_string_key/1
  defp list_item(item) when is_map(item), do: &deep_string_key/1
  defp list_item(item) when is_list(item), do: for(k <- item, into: [], do: list_item(k))
  defp list_item(item), do: item

  @spec deep_compactor(map) :: map
  @spec deep_compactor(list) :: list
  def deep_compactor(map) when is_map(map) do
    map
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      cond do
        is_struct(v) -> Map.put_new(acc, k, v)
        is_map(v) and Enum.empty?(v) -> acc
        is_map(v) or is_list(v) -> Map.put_new(acc, k, deep_compactor(v))
        is_nil(v) -> acc
        true -> Map.put_new(acc, k, v)
      end
    end)
  end

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
