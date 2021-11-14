defmodule Remedy.LogHelpers do
  @moduledoc false
  require Logger

  def log_malformed(event) do
    Logger.warning("#{event} RECEIVED WITH MALFORMED PAYLOAD")
  end

  def log_db_error(event, reason) do
    Logger.warning("#{event} ERROR: #{reason}")
  end
end
