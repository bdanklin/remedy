defmodule Remedy.Gateway.Events.UpdatePresence do
  @moduledoc false
  use Remedy.Gateway.Payload

  embedded_schema do
    field :since, :integer, default: 91_879_201
    field :status, :string, default: "online"
    field :afk, :boolean, default: false
    embeds_one :activity, Activity
  end

  def payload(_socket, opts \\ []) do
    %__MODULE__{
      since: opts["since"] || 91_879_201,
      status: opts["status"] || "online",
      afk: opts["afk"] || false,
      activity: opts["activity"]
    }
  end
end
