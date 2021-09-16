defmodule Remedy.Schema.Presence do
  @moduledoc false
  use Remedy.Schema
  @primary_key {:code, :string, autogenerate: false}

  schema "presences" do
    belongs_to :user, User
    field :guild_id, Snowflake
    field :status, :string
    embeds_many :activities, Activity
    embeds_one :client_status, ClientStatus
  end

  def validate(changeset) do
    changeset
    |> validate_inclusion(:status, ["idle", "dnd", "online", "offline"])
  end
end
