defmodule Remedy.Schema.EmbedAuthor do
  @moduledoc """
  Discord Embed Author Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          url: String.t(),
          icon_url: String.t(),
          proxy_icon_url: String.t()
        }

  embedded_schema do
    field :name
    field :url
    field :icon_url
    field :proxy_icon_url
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
