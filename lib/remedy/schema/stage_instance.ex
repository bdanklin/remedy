defmodule Remedy.Schema.StageInstance do
  @moduledoc """
  Stage Instance
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          topic: String.t(),
          privacy_level: integer(),
          discoverable_disabled: boolean(),
          guild: Guild.t(),
          channel: Channel.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "stage_instances" do
    field :topic, :string
    field :privacy_level, :integer
    field :discoverable_disabled, :boolean
    belongs_to :guild, Guild
    belongs_to :channel, Channel
    # field :tags,  :	role tags object	the tags this role has
  end

  def form(params), do: params |> changeset() |> apply_changes()
  @doc false
  def shape(model, params), do: model |> changeset(params) |> apply_changes()

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
