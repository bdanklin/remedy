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

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
  end

  def validate(changeset), do: changeset

  def changeset(params), do: changeset(%__MODULE__{}, params)
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = model, params) do
    cast(model, params, castable())
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
