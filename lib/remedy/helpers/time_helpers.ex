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
end
