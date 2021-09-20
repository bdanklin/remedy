defmodule Remedy.Schema.PermissionOverwrite do
  @moduledoc false
  # type	int	either 0 (role) or 1 (member) <- use to build changeset
  use Remedy.Schema
  @primary_key false

  embedded_schema do
    field :id, Snowflake, virtual: true
    embeds_one :role, Role
    embeds_one :user, User
    field :type, :integer
    field :allow, :string
    field :deny, :string
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
