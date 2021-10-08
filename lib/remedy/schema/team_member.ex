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

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(changeset) do
    changeset
  end

  @doc false
  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
