defmodule Remedy.Schema.EmbedField do
  @moduledoc """
  Embed Field Object
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

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:name, :value, :inline])
    |> validate_required([:name, :value])
    |> validate_length(:name, max: 256)
    |> validate_length(:value, max: 1024)
  end
end
