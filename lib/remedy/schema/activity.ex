defmodule Remedy.Schema.Activity do
  @moduledoc """
  Discord Activity Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          type: integer(),
          party_id: String.t()
        }

  @primary_key false
  embedded_schema do
    field :name, :string
    field :type, :integer
    field :party_id, :string
  end

  @doc false
  def new(params) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_changes()
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
