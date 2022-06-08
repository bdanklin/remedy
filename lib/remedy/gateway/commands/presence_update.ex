defmodule Remedy.Gateway.Commands.PresenceUpdate do
  @moduledoc false
  #############################################################################
  ## 3
  ## Presence Update
  ## Send
  ## Update the client's presence.

  use Remedy.Schema

  embedded_schema do
    field :since, Timestamp
    field :status, :string, default: "online"
    field :afk, :boolean, default: false
    embeds_many :activities, BotActivity
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [:since, :status, :afk, :activity])
  end

  def send(_socket, opts) do
    %{
      since: opts[:since],
      status: opts[:status],
      afk: opts[:afk],
      activities: opts[:activity]
    }
    |> changeset()
  end
end
