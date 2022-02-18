defmodule Remedy.Consumer.LumberJack do
  @moduledoc false
  use Remedy.Consumer
  require Logger

  @doc false
  @spec handle_event({any, any}, any) :: :ok
  def handle_event({event, _payload}, _meta) do
    Logger.debug("#{inspect(event)} ")
  end
end
