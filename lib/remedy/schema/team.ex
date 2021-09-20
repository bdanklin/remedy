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
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
