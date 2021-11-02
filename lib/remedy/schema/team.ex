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

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end

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

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
