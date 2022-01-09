defmodule Remedy.Schema.EmbedField do
  @moduledoc """
  Discord Embed Field Object
  """
  use Remedy.Schema

  @typedoc """
  Formed EmbedField Type.
  """
  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t(),
          inline: boolean()
        }

  @typedoc """
  EmbedField params.
  """
  @type p :: %{
          required(:name) => String.t(),
          required(:value) => String.t(),
          optional(:inline) => boolean()
        }

  @typedoc """
  Castable to EmbedField Type
  """
  @type c :: t | p

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
