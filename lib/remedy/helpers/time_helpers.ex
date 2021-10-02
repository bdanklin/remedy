defmodule Remedy.TimeHelpers do
  @moduledoc false

  @doc """
  Returns the number of ms since the Discord epoch.
  """
  def utc_now_ms do
    DateTime.utc_now()
    |> DateTime.to_unix(:millisecond)
  end

  @doc """
  Returns the number of milliseconds since unix epoch.
  """
  @spec now() :: integer
  def now do
    DateTime.utc_now()
    |> DateTime.to_unix(:millisecond)
  end

  @doc """
  Returns the number of microseconds since unix epoch.
  """
  @spec usec_now() :: integer
  def usec_now do
    DateTime.utc_now()
    |> DateTime.to_unix(:microsecond)
  end

  @doc """
  Returns the current date as an ISO formatted string.
  """
  @spec now_iso() :: String.t()
  def now_iso do
    DateTime.utc_now()
    |> DateTime.to_iso8601()
  end

  def discord_epoch, do: 1_420_070_400_000

  @doc """
    Returns the creation time of the snowflake.

    ## Examples

        iex> Nostrum.Snowflake.creation_time(177888205536886784)
        ~U[2016-05-05 21:04:13.203Z]

  """
  @spec creation_time(any()) :: DateTime.t()
  def creation_time(snowflake) do
    use Bitwise

    time_elapsed_ms = (snowflake >>> 22) + discord_epoch()

    {:ok, datetime} = DateTime.from_unix(time_elapsed_ms, :millisecond)
    datetime
  end
end
