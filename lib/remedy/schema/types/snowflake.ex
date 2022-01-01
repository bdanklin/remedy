defmodule Remedy.Snowflake do
  @moduledoc """
  Discord Snowflake Type

  """
  import Remedy.TimeHelpers
  use Ecto.Type
  use Unsafe.Generator, handler: :unwrap, docs: false

  @typedoc """
  A discord snowflake.

  0x400000..0xFFFFFFFFFFFFFFFF

  """
  @type t() :: 0x400000..0xFFFFFFFFFFFFFFFF

  @doc false
  @impl true
  @spec type :: :integer
  def type, do: :integer

  @doc false
  @impl true
  @unsafe {:cast, [:value]}
  def cast(value)
  def cast(nil), do: {:ok, nil}
  def cast(value) when is_snowflake(value), do: {:ok, value}
  def cast(value) when is_binary(value), do: {:ok, String.to_integer(value)}
  def cast(_value), do: :error

  @doc false
  @impl true
  @unsafe {:dump, [:snowflake]}
  def dump(nil), do: {:ok, nil}
  def dump(value) when is_snowflake(value), do: {:ok, value}
  def dump(value) when is_binary(value), do: {:ok, String.to_integer(value)}
  def dump(_value), do: :error

  @doc false
  @impl true
  def load(value) when is_snowflake(value), do: {:ok, value}

  @doc false
  @impl true
  def equal?(term1, term2), do: to_unixtime(term1) == to_unixtime(term2)

  @doc false
  @impl true
  def embed_as(_value), do: :dump

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise(ArgumentError)
end
