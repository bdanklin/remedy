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

  def validate(changeset) do
    changeset
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
