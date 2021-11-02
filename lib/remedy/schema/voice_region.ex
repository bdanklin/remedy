defmodule Remedy.Schema.VoiceRegion do
  @moduledoc """
  Voice Region
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          name: String.t(),
          vip: boolean(),
          optimal: boolean(),
          deprecated: boolean(),
          custom: boolean()
        }

  @primary_key {:id, :string, autogenerate: false}
  schema "voice_regions" do
    field :name, :string
    field :vip, :boolean
    field :optimal, :boolean
    field :deprecated, :boolean
    field :custom, :boolean
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
