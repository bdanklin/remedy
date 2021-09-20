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

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
  end

  def validate(changeset), do: changeset

  def changeset(params), do: changeset(%__MODULE__{}, params)
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = model, params) do
    cast(model, params, castable())
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
