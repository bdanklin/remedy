defmodule Remedy.Schema.Team do
  use Remedy.Schema, :model
  alias Remedy.Schema.TeamMember

  @primary_key {:id, :id, autogenerate: false}
  schema "teams" do
    field :icon, :string
    field :name, :string
    field :owner_user_id, Snowflake
    has_many :members, TeamMember
  end
end
