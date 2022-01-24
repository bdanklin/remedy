defmodule Remedy.Gateway.Commands.PresenceUpdate do
  @moduledoc false
  defstruct since: 91_879_201,
            status: "online",
            afk: false,
            activity: nil

  def send(_socket, opts) do
    %__MODULE__{
      since: opts[:since] || 91_879_201,
      status: opts[:status] || "online",
      afk: opts[:afk] || false,
      activity: opts[:activity]
    }
  end
end
