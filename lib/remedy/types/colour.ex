defmodule Remedy.Colour do
  @moduledoc """
  Ecto.Type implementation of Colours.

  Data will be saved as an integer, for example `"#FF0000"` will be saved as `16711680`, which is the decimal representation of `0xFF0000`.

  ## Casting

  The following are examples of valid inputs for casting. Regardless of the format provided, values will be cast to an `t:integer/0` value for storage.

  #### Hex Code as a string

      "#FF0000"


  #### Hex Code as a string.

      "#F00"


  #### Hex code as an integer

      0xFF0000


  #### Decimal representation

      16711680

  """
  import Remedy.ColourHelpers
  use Remedy.UnsafeHelpers, handler: :unwrap, docs: false
  use Ecto.Type

  @typedoc """
  A _so called_ Colour Type.
  """
  @type t :: 0x000000..0xFFFFFF

  @typedoc """
  Castable to Colour.
  """
  @type c :: integer() | String.t() | {r :: 0x00..0xFF, g :: 0x00..0xFF, b :: 0x00..0xFF}

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
  def cast(value), do: {:ok, to_hex(value)}

  @doc false
  @impl true
  @unsafe {:dump, [:value]}
  @spec dump(any) :: :error | {:ok, nil | binary}
  def dump(nil), do: {:ok, nil}
  def dump(value), do: {:ok, to_integer(value)}

  @doc false
  @impl true
  @unsafe {:load, [:value]}
  @spec load(any) :: {:ok, String.t()}
  def load(value), do: {:ok, to_hex(value)}

  @doc false
  @impl true
  def equal?(term1, term2), do: to_integer(term1) == to_integer(term2)

  @doc false
  @impl true
  def embed_as(_value), do: :dump

  defp unwrap({:ok, body}), do: body
  defp unwrap(:error), do: raise(ArgumentError)
end
