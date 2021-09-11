defmodule Remedy.Schema.PresenceUpdate do
  @moduledoc false
  use Remedy.Schema
  @primary_key {:id, Snowflake, autogenerate: false}

  # either "idle", "dnd", "online", or "offline"

  embedded_schema do
    belongs_to :user, User
    belongs_to :guild, Guild
    field :status, :string
    embeds_one :client_status, ClientStatus
    embeds_many :activities, Activity
  end
end
