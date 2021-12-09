defmodule Remedy.Schema.MessageFlags do
  @moduledoc false
  use Remedy.Schema
  use BattleStandard

  @flag_bits [
    CROSSPOSTED: 1 <<< 0,
    IS_CROSSPOST: 1 <<< 1,
    SUPPRESS_EMBEDS: 1 <<< 2,
    SOURCE_MESSAGE_DELETED: 1 <<< 3,
    URGENT: 1 <<< 4,
    HAS_THREAD: 1 <<< 5,
    EPHEMERAL: 1 <<< 6,
    LOADING: 1 <<< 7
  ]

  @type t :: %__MODULE__{
          CROSSPOSTED: boolean(),
          IS_CROSSPOST: boolean(),
          SUPPRESS_EMBEDS: boolean(),
          SOURCE_MESSAGE_DELETED: boolean(),
          URGENT: boolean(),
          HAS_THREAD: boolean(),
          EPHEMERAL: boolean(),
          LOADING: boolean()
        }

  embedded_schema do
    field :CROSSPOSTED, :boolean, default: false
    field :IS_CROSSPOST, :boolean, default: false
    field :SUPPRESS_EMBEDS, :boolean, default: false
    field :SOURCE_MESSAGE_DELETED, :boolean, default: false
    field :URGENT, :boolean, default: false
    field :HAS_THREAD, :boolean, default: false
    field :EPHEMERAL, :boolean, default: false
    field :LOADING, :boolean, default: false
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
