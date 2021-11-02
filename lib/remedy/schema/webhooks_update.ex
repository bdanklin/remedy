defmodule Remedy.Schema.WebhooksUpdate do
  @moduledoc false
  use Remedy.Schema

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          channel_id: Snowflake.t()
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
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
