defmodule Remedy.Colour do
  @moduledoc """
  Ecto.Type implementation of Colours used in discord embeds.

  Data will be saved as an integer, for example `"#FF0000"` will be saved as `16711680`, which is the decimal representation of `0xFF0000`.

  It can be accepted in a number of forms:

  ```elixir
  # 6 element Hex code as a string
  "#FF0000"

  # 3 element Hex code as a string
  "#F00"

  # 6 element Hex code as an integer
  0xFF0000

  # Decimal representation
  16711680

  """
  import Remedy.ColourHelpers
  use Unsafe.Generator, handler: :unwrap, docs: true
  use Ecto.Type

  @typedoc """
  A _so-called_ color according to _so-called_ discord.
  """

  @type t :: String.t()

  @doc false
  @impl true
  @spec type :: :integer
  def type, do: :integer

  @doc false
  @impl true
  @unsafe {:cast, [:value]}
  @spec cast(any) :: :error | {:ok, nil | binary}
  def cast(value)
  def cast(nil), do: {:ok, nil}
  def cast(value), do: {:ok, to_integer(value)}

  @doc false
  @impl true
  @unsafe {:dump, [:value]}
  @spec dump(any) :: :error | {:ok, nil | binary}
  def dump(nil), do: {:ok, nil}
  def dump(value), do: {:ok, to_integer(value)}

  @doc false
  @impl true
  @unsafe {:load, [:value]}
  @spec load(any) :: {:ok, t() | nil}
  def load(value), do: {:ok, to_hex(value)}

  @doc false
  @impl true
  def equal?(term1, term2), do: to_integer(term1) == to_integer(term2)

  @doc false
  @impl true
  def embed_as(_value), do: :dump

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise(ArgumentError)
end
