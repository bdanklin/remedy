defmodule Remedy.TimeHelpers do
  @moduledoc """
  Functions and Guards for working with time.

  There are four formats of concern in this module:

  - `Snowflake` - a 64-bit integer representing the number of milliseconds since the discord epoch + metadata.
  - `t:DateTime/0` - a datetime.datetime object.
  - `ISO8601` - a string in the ISO8601 format.
  - `UnixTime` - a number representing the number of seconds since the unix epoch.



  """
  use Bitwise

  @doc """
  Guard to test if a value is a Snowflake.
  """
  @doc section: :guards
  defguard is_snowflake(value) when is_integer(value) and value > 0x400000 and value < 0xFFFFFFFFFFFFFFFF

  @doc """
  Guard to test if a value is probably a unix_time.
  """
  @doc section: :guards
  defguard is_unixtime(value) when is_integer(value) and value > 0 and value < 0xFFFFFFFFFFFFFFFF

  @doc """
  Guard to test if a value is a `DateTime`.
  """
  @doc section: :guards
  defguard is_datetime(value) when is_struct(value, DateTime)

  @doc """
  Guard to test if a value is an ISO8601 encoded string.
  """
  @doc section: :guards
  defguard is_iso8601(value) when is_binary(value)

  @doc """
  Returns the discord epoch: `1_420_070_400_000`
  """
  def discord_epoch, do: 1_420_070_400_000

  @doc """
  Convert a value to an elixir `DateTime`

  ## Examples

      iex> Remedy.TimeHelpers.to_datetime(nil)
      nil

      iex> Remedy.TimeHelpers.to_datetime(15824000000000)
      ~U[2015-01-01T01:02:52.735Z]

      iex> Remedy.TimeHelpers.to_datetime(919970797920067654)
      ~U[2021-12-13T15:15:30.455Z]

      iex> Remedy.TimeHelpers.to_datetime("2021-12-13T15:13:33.774426Z")
      ~U[2021-12-13T15:13:33.774426Z]

      iex> Remedy.TimeHelpers.to_datetime(:some_atom)
      :error


  """
  def to_datetime(nil), do: nil
  def to_datetime(value) when is_binary(value), do: DateTime.from_iso8601(value) |> elem(1)
  def to_datetime(value) when is_datetime(value), do: value

  def to_datetime(value) when is_snowflake(value) do
    ((value >>> 22) + discord_epoch()) |> DateTime.from_unix!(:millisecond)
  end

  def to_datetime(_value), do: :error

  @doc """
  Convert a value to a string representation of the ISO8601 format.

  ## Examples

      iex Remedy.TimeHelpers.to_iso8601(nil)
      nil

      iex> Remedy.TimeHelpers.to_iso8601(15824000000000)
      "2015-01-01T01:02:52.735Z"

      iex> Remedy.TimeHelpers.to_iso8601(919970797920067654)
      "2021-12-13T15:15:30.455Z"

      iex> Remedy.TimeHelpers.to_iso8601("2021-12-13T15:13:33.774426Z")
      "2021-12-13T15:13:33.774426Z"

      iex Remedy.TimeHelpers.to_iso8601(:some_atom)
      :error

  """
  @doc since: "0.6.8"
  @spec to_iso8601(any) :: binary() | nil

  def to_iso8601(value)
  def to_iso8601(nil), do: nil
  def to_iso8601(value) when is_datetime(value), do: to_string(value)
  def to_iso8601(value) when is_iso8601(value), do: DateTime.from_iso8601(value) |> elem(1) |> to_string()

  def to_iso8601(value) when is_snowflake(value) do
    ((value >>> 22) + discord_epoch()) |> DateTime.from_unix!(:millisecond) |> to_string()
  end

  def to_iso8601(value) when is_integer(value) do
    case System.os_time(:second) > value do
      true -> DateTime.from_unix!(value, :millisecond) |> to_string()
      false -> DateTime.from_unix!(value, :second) |> to_string()
    end
  end

  def to_iso8601(_value), do: :error

  @doc """
  Convert a value to its unix time.

  ## Examples

      iex Remedy.TimeHelpers.to_unixtime(nil)
      nil

      iex> Remedy.TimeHelpers.to_unixtime(15824000000000)
      1639408530455

      iex> Remedy.TimeHelpers.to_unixtime(919970797920067654)
      1639408530455

      iex> Remedy.TimeHelpers.to_unixtime("2021-12-13T15:13:33.774426Z")
      1639408530455

      iex Remedy.TimeHelpers.to_unixtime(:some_atom)
      :error

  """
  def to_unixtime(nil), do: nil

  def to_unixtime(value) when is_snowflake(value) do
    (value >>> 22) + discord_epoch()
  end

  def to_unixtime(value) when is_datetime(value) do
    value |> DateTime.to_unix(:millisecond)
  end

  def to_unixtime(value) when is_iso8601(value) do
    DateTime.from_iso8601(value) |> elem(1) |> DateTime.to_unix(:millisecond)
  end

  def to_unixtime(_value), do: :error
end
