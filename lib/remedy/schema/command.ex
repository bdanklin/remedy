defmodule Remedy.Schema.Command do
  @moduledoc """
  Discord Command Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: integer(),
          name: String.t(),
          description: String.t(),
          default_permission: boolean(),
          application: App.t(),
          guild: Guild.t(),
          options: Option.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :type, :integer, default: 1
    field :name, :string
    field :description, :string
    field :default_permission, :boolean, default: true
    belongs_to :application, App
    belongs_to :guild, Guild
    embeds_many :options, Option
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

  def validate(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 32)
  end
end
