defmodule Remedy.Schema.TeamMember do
  use Remedy.Schema, :model

  @primary_key false
  schema "team_members" do
    field :membership_state, :integer
    field :permissions, {:array, :string}
    belongs_to :team, Team
    belongs_to :user, User
  end
end
