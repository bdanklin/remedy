defmodule Remedy.Schema.Team do
  @moduledoc """
  Discord Team Object
  """
  use Remedy.Schema
  alias Remedy.Schema.TeamMember

  @type t :: %__MODULE__{
          icon: String.t(),
          name: String.t(),
          owner_user_id: Snowflake.t(),
          application: App.t(),
          team_members: [TeamMember.t()]
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :icon, :string
    field :name, :string
    field :owner_user_id, Snowflake
    has_one :application, App
    has_many :team_members, TeamMember
  end
end
