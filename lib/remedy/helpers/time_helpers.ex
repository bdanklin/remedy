defmodule Remedy.TimeHelpers do
  @moduledoc """
  Time Helpers
  """

  @doc """
  Returns the number of ms since the Discord epoch.
  """
  def utc_now_ms do
    DateTime.utc_now()
    |> DateTime.to_unix(:millisecond)
  end
end
