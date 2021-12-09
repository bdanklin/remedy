defmodule Remedy.Schema.StageInstance do
  @moduledoc """
  Stage Instance
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          topic: String.t(),
          privacy_level: integer(),
          discoverable_disabled: boolean(),
          guild_id: Snowflake.t(),
          channel_id: Snowflake.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "stage_instances" do
    field :topic, :string
    field :privacy_level, :integer
    field :discoverable_disabled, :boolean
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    # field :tags,  :	role tags object	the tags this role has
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
