defmodule Remedy.ISO8601 do
  @moduledoc """
  Ecto.Type implementation of ISO8601 date-time strings.

  Data will be saved as a string field in the database in the form of

  ```elixir
  "2015-01-01T01:02:52.735Z"
  ```

  It can be provided to this function in unixtime, as a Snowflake, a string representation of the ISO8601 date, or a DateTime object.
  """
  import Remedy.TimeHelpers
  use Unsafe.Generator, handler: :unwrap, docs: true
  use Ecto.Type

  @typedoc "A date-time string in ISO8601 format."
  @type t :: binary()

  @impl true
  @spec type :: :string
  def type, do: :string

  @impl true
  @unsafe {:cast, [:value]}
  @spec cast(any) :: :error | {:ok, nil | binary}
  def cast(value)
  def cast(nil), do: {:ok, nil}
  def cast(value) when is_iso8601(value), do: {:ok, to_iso8601(value)}
  def cast(value) when is_datetime(value), do: {:ok, to_iso8601(value)}
  def cast(value) when is_unixtime(value), do: {:ok, to_iso8601(value)}
  def cast(_value), do: :error

  @impl true
  @unsafe {:dump, [:value]}
  @spec dump(any) :: :error | {:ok, nil | binary}
  def dump(nil), do: {:ok, nil}
  def dump(value) when is_unixtime(value), do: {:ok, to_iso8601(value)}
  def dump(value) when is_iso8601(value), do: {:ok, to_iso8601(value)}
  def dump(value) when is_datetime(value), do: {:ok, to_iso8601(value)}
  def dump(_value), do: :error

  @impl true
  @unsafe {:load, [:value]}
  @spec load(any) :: {:ok, t() | nil}
  def load(value), do: {:ok, value}

  @impl true
  def equal?(term1, term2), do: to_iso8601(term1) == to_iso8601(term2)

  @impl true
  def embed_as(_value), do: :dump

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise(ArgumentError)
end
