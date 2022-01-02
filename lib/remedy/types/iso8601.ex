defmodule Remedy.ISO8601 do
  @moduledoc """
  `Ecto.Type` compatible limited ISO8601 type.

  ISO8601 is an international standard covering the worldwide exchange and communication of date and time related data. It is maintained by the Geneva-based International Organization for Standardization (ISO) and was first published in 1988, with updates in 1991, 2000, 2004, and 2019. The standard aims to provide a well-defined, unambiguous method of representing calendar dates and times in worldwide communications, especially to avoid misinterpreting numeric dates and times when such data is transferred between countries with different conventions for writing numeric dates and times.

  This implementation is limited in that it does not handle ranges of dates, and it does not handle time zones. It provides conveniences for conversion of Snowflakes, Unix Timestamps and DateTime structs. A field that accepts an ISO8601 date can therefore accept any of the mentioned formats. The data will be parsed and cast automatically.

  ## Casting

  The following are examples of valid inputs for casting. Regardless of the format provided, values will be cast to a `t:binary/0` value for storage.

  #### ISO8601 Timestamp

      "2015-01-01T01:02:52.735Z"


  #### Unix Timestamp

      1420070400


  #### DateTime Struct

      %DateTime{year: 2015, month: 1, day: 1, hour: 1, minute: 2,
      second: 52, millisecond: 735, microsecond: 0, nanosecond: 0, timezone: nil}


  It can be provided to this function in unixtime, as a Snowflake, a string representation of the ISO8601 date, or a DateTime object.
  """
  import Remedy.TimeHelpers
  use Unsafe.Generator, handler: :unwrap, docs: false
  use Ecto.Type

  @typedoc """
  An ISO8601 Type.
  """
  @type t() :: String.t()

  @typedoc """
  Castable to ISO8601 Type.
  """
  @type c() :: DateTime.t() | String.t() | ISO8601.t() | nil

  @doc false
  @impl true
  @spec type :: :string
  def type, do: :string

  @doc false
  @impl true
  @unsafe {:cast, [:value]}
  @spec cast(any) :: :error | {:ok, nil | binary}
  def cast(value)
  def cast(nil), do: {:ok, nil}
  def cast(value) when is_iso8601(value), do: {:ok, to_iso8601(value)}
  def cast(value) when is_datetime(value), do: {:ok, to_iso8601(value)}
  def cast(value) when is_unixtime(value), do: {:ok, to_iso8601(value)}
  def cast(_value), do: :error

  @doc false
  @impl true
  @unsafe {:dump, [:value]}
  @spec dump(any) :: :error | {:ok, nil | binary}
  def dump(nil), do: {:ok, nil}
  def dump(value) when is_unixtime(value), do: {:ok, to_iso8601(value)}
  def dump(value) when is_iso8601(value), do: {:ok, to_iso8601(value)}
  def dump(value) when is_datetime(value), do: {:ok, to_iso8601(value)}
  def dump(_value), do: :error

  @doc false
  @impl true
  @unsafe {:load, [:value]}
  @spec load(any) :: {:ok, t() | nil}
  def load(value), do: {:ok, value}

  @doc false
  @impl true
  def equal?(term1, term2), do: to_iso8601(term1) == to_iso8601(term2)

  @doc false
  @impl true
  def embed_as(_value), do: :dump

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise(ArgumentError)
end
