defmodule Remedy.Schema.ClientStatus do
  @moduledoc """
  Discord Client Status Object
  """
  use Remedy.Schema
  @primary_key false

  @type t :: %__MODULE__{
          desktop: String.t(),
          mobile: String.t(),
          web: String.t()
        }

  embedded_schema do
    field :desktop, :string
    field :mobile, :string
    field :web, :string
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
