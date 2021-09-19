defmodule Remedy.Schema.TeamMember do
  @moduledoc """
  Discord Team Member Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          membership_state: integer(),
          permissions: [String.t()],
          team: Team.t(),
          user: User.t()
        }

  @primary_key false
  embedded_schema do
    field :membership_state, :integer
    field :permissions, {:array, :string}
    belongs_to :team, Team
    belongs_to :user, User
  end
end
