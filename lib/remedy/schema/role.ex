defmodule Remedy.Schema.Role do
  @moduledoc """
  Role
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          color: integer(),
          hoist: boolean(),
          position: integer(),
          permissions: String.t(),
          managed: boolean(),
          mentionable: boolean(),
          guild: Guild.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "roles" do
    field :name, :string
    field :color, :integer
    field :hoist, :boolean
    field :position, :integer
    field :permissions, :string
    field :managed, :boolean
    field :mentionable, :boolean
    belongs_to :guild, Guild
    # field :tags,  :	role tags object	the tags this role has
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
