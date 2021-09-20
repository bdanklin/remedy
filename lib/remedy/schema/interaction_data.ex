defmodule Remedy.Schema.InteractionData do
  @moduledoc """
  This is the center point between Commands, Interactions and Components.

  Should probably be the center point of any command framework
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          name: String.t(),
          type: integer(),
          custom_id: String.t(),
          component_type: integer(),
          values: [String.t()],
          target_id: Snowflake.t(),
          resolved: InteractionDataResolved.t(),
          options: [InteractionDataOption.t()]
        }

  @primary_key false
  embedded_schema do
    field :id, Snowflake
    field :name, :string
    field :type, :integer
    field :custom_id, :string
    field :component_type, :integer
    field :values, {:array, :string}
    field :target_id, Snowflake
    embeds_one :resolved, InteractionDataResolved
    embeds_many :options, InteractionDataOption
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
