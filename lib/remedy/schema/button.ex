defmodule Remedy.Schema.Button do
  use Remedy.Schema

  embedded_schema do
    field :type, ComponentType, default: 2
    field :style, ButtonStyle
    field :label, :string
    embeds_one :emoji, Emoji
    field :custom_id, :string
    field :disabled, :boolean
    field :url, URL
  end

  def changeset(model \\ %__MODULE__{}, attrs)

  ## command button
  def changeset(model, %{custom_id: _} = attrs) do
    model
    |> cast(attrs, [:style, :label, :custom_id, :disabled])
    |> cast_embed(:emoji)
    |> validate_required([:type, :style])
  end

  ## link button
  def changeset(model, %{url: _} = attrs) do
    model
    |> cast(attrs, [:style, :label, :disabled, :url])
    |> cast_embed(:emoji)
    |> validate_required([:type, :style])
  end
end
