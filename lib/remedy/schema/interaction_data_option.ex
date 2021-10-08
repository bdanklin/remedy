defmodule Remedy.Schema.InteractionDataOption do
  @moduledoc """
  Interaction Data Option Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          type: integer(),
          value: String.t(),
          options: [__MODULE__.t()]
        }

  embedded_schema do
    field :name, :string
    field :type, :integer
    field :value, :string
    embeds_many :options, __MODULE__
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
