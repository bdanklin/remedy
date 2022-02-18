defmodule Remedy.TimeHelpers do
  @moduledoc """
  Functions and Guards for working with time.

  There are four formats of concern in this module:

  - `Snowflake` - a 64-bit integer representing the number of milliseconds since the discord epoch + metadata.
  - `t:DateTime/0` - a datetime.datetime object.
  - `t:Remedy.ISO8601.t/0` - a string in the ISO8601 format.
  - `UnixTime` - a number representing the number of seconds since the unix epoch.

  """
  use Remedy.UnsafeHelpers, handler: :unwrap, docs: false
  use Bitwise

  @iso8601_regex ~r/^([\+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T\s]((([01]\d|2[0-3])((:?)[0-5]\d)?|24\:?00)([\.,]\d+(?!:))?)?(\17[0-5]\d([\.,]\d+)?)?([zZ]|([\+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$/

  @discord_epoch 1_420_070_400_000
  @doc "Returns the discord epoch."
  @spec discord_epoch :: 1_420_070_400_000
  def discord_epoch, do: @discord_epoch

  defguard is_snowflake(value)
           when is_integer(value) and
                  value > 0x400000 and
                  value < 0xFFFFFFFFFFFFFFFF

  defguard is_unixtime(value)
           when is_integer(value) and
                  value > 0 and
                  value < 0xFFFFFFFFFFFFFFFF

  @doc "Guard to test if a value is a `DateTime`."
  @doc section: :guards
  defguard is_datetime(value)
           when is_struct(value, DateTime)

  @spec is_datetime?(any) :: boolean()
  @doc """
  Check if the term is a valid `t:DateTime.t/0`.

  ## Examples

      iex> date_time = DateTime.now!("Etc/UTC")
      ...> Remedy.TimeHelpers.is_datetime?(date_time)
      true

      iex> "2020-01-01T00:00:00Z" |> Remedy.TimeHelpers.is_datetime?()
      false

  """
  def is_datetime?(value) when is_datetime(value), do: true
  def is_datetime?(_), do: false

  @spec is_unixtime?(any) :: boolean
  @doc "Check if the term is a valid `t:DateTime.t/0`."
  def is_unixtime?(value) when is_unixtime(value), do: true
  def is_unixtime?(_), do: false

  @spec is_snowflake?(any) :: boolean
  @doc " Function to test if a term is an integer snowflake or binary snowflake"
  def is_snowflake?(value) when is_snowflake(value), do: true
  def is_snowflake?(value) when is_binary(value), do: Integer.parse(value) |> parse_maybe_snowflake()
  def is_snowflake?(_), do: false

  defp parse_maybe_snowflake({value, ""}), do: is_snowflake?(value)
  defp parse_maybe_snowflake({num, _binary}) when not is_snowflake(num), do: false

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
  @spec to_datetime(any) :: DateTime.t() | nil | :error
  def to_datetime(nil), do: nil

  def to_datetime(value) do
    cond do
      is_datetime?(value) -> value
      is_iso8601?(value) -> iso8601_to_datetime(value)
      is_snowflake?(value) -> snowflake_to_datetime(value)
      is_unixtime?(value) -> unixtime_to_datetime(value)
      true -> :error
    end
  end

  defp iso8601_to_datetime(value) do
    dt = DateTime.from_iso8601(value)

    case dt do
      {:ok, dt, _} -> dt
      {:error, _} -> :error
    end
  end

  defp snowflake_to_datetime(value) do
    ((String.to_integer(to_string(value)) >>> 22) + @discord_epoch)
    |> DateTime.from_unix!(:millisecond)
  end

  defp unixtime_to_datetime(_val) do
    false
  end

  @doc """
  Test if a value is an ISO8601 encoded string.
  """

  def is_iso8601?(value) do
    value |> to_string() |> String.match?(@iso8601_regex)
  end

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

  def to_iso8601(value)
  def to_iso8601(nil), do: nil

  def to_iso8601(value) do
    iso8601 =
      cond do
        is_iso8601?(value) -> iso8601_format(value)
        is_datetime?(value) -> datetime_to_iso8601(value)
        is_snowflake?(value) -> snowflake_to_iso8601(value)
        is_unixtime?(value) -> unixtime_to_iso8601(value) |> datetime_to_iso8601()
        true -> :error
      end

    iso8601_format(iso8601)
  end

  defp datetime_to_iso8601(%DateTime{} = value), do: value
  defp datetime_to_iso8601({:ok, t, _}), do: t
  defp datetime_to_iso8601({:error, _atom}), do: :error

  defp snowflake_to_iso8601(value) do
    value = value |> to_string |> String.to_integer()
    ((value >>> 22) + discord_epoch()) |> DateTime.from_unix!(:millisecond)
  end

  defp unixtime_to_iso8601(value) when is_integer(value) do
    case System.os_time(:second) > value do
      true -> DateTime.from_unix!(value, :millisecond)
      false -> DateTime.from_unix!(value, :second)
    end
  end

  defp iso8601_format(:error), do: :error
  defp iso8601_format(value), do: value |> to_string() |> String.replace(" ", "T")

  #############################################################################
  ######## UnixTime ## UnixTime ## UnixTime ## UnixTime ## UnixTime ########### #############################################################################

  @doc """
  Convert a value to its unix time.

  ## Examples

      iex Remedy.TimeHelpers.to_unixtime(nil)
      nil

      iex> Remedy.TimeHelpers.to_unixtime(797634639408530455)
      1610241317369

      iex> Remedy.TimeHelpers.to_unixtime("2021-01-10T01:15:17.369Z")
      1610241317369

      iex> date_time = DateTime.now!("Etc/UTC")
      ...> Remedy.TimeHelpers.to_unixtime(date_time)

      iex Remedy.TimeHelpers.to_unixtime(:some_atom)
      :error

  """
  def to_unixtime(nil), do: nil

  def to_unixtime(value) do
    cond do
      is_snowflake?(value) -> snowflake_to_unixtime(value)
      is_datetime?(value) -> datetime_to_unixtime(value)
      is_iso8601?(value) -> iso8601_to_unixtime(value)
      true -> :error
    end
  end

  defp snowflake_to_unixtime(value), do: (value >>> 22) + discord_epoch()

  defp iso8601_to_unixtime(value) when is_binary(value), do: DateTime.from_iso8601(value) |> datetime_to_unixtime()

  defp datetime_to_unixtime(%DateTime{} = value), do: DateTime.to_unix(value, :millisecond)
  defp datetime_to_unixtime({:ok, datetime, _}), do: datetime |> DateTime.to_unix(:millisecond)
  defp datetime_to_unixtime({:error, _atom}), do: :error

  #############################################################################
  ####### Snowflake ## Snowflake ## Snowflake ## Snowflake ## Snowflake ####### #############################################################################

  def to_snowflake(value) when is_datetime(value) do
    (DateTime.to_unix(value, :millisecond) - discord_epoch()) <<< 22
  end

  def to_snowflake(value) when is_binary(value) do
    cond do
      is_snowflake?(value) -> String.to_integer(value)
      is_iso8601?(value) -> DateTime.from_iso8601(value) |> elem(1) |> to_snowflake()
    end
  end

  def to_snowflake(value) when is_snowflake(value) do
    value
  end

  def to_snowflake(_value), do: :error
end
