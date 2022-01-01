defmodule Remedy.Schema.EmbedField do
  @moduledoc """
  Discord Embed Field Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t(),
          inline: boolean()
        }

  @primary_key false
  embedded_schema do
    field :name
    field :value
    field :inline, :boolean, default: false
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:name, :value, :inline])
    |> validate_required([:name, :value])
  end
end
