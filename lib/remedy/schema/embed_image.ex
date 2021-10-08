defmodule Remedy.Schema.EmbedImage do
  @moduledoc """
  Discord Embed Image Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          url: String.t(),
          proxy_url: String.t(),
          height: integer(),
          width: integer()
        }

  embedded_schema do
    field :url, :string
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
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
