defmodule Remedy.Schema.Reference do
  @moduledoc """
  Reference Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          message: Message.t(),
          channel: Channel.t(),
          guild: Guild.t()
        }

  @primary_key false
  embedded_schema do
    belongs_to :message, Message
    belongs_to :channel, Channel
    belongs_to :guild, Guild
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
