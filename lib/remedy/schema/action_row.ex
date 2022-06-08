defmodule Remedy.Schema.ActionRow do
  @moduledoc """
  Action Row Object
  """
  use Remedy.Schema

  @primary_key false
  embedded_schema do
    field :type, :integer, default: 1
    embeds_many :components, Component
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [])
    |> cast_embed(:components)
    |> validate_required([:type])
  end
end
