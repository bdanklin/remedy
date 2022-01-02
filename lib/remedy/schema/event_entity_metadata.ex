defmodule Remedy.Schema.EventEntityMetadata do
  use Remedy.Schema

  @type t :: %__MODULE__{
          location: String.t()
        }

  @primary_key false
  embedded_schema do
    field :location, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:location])
    |> validate_length(:location, min: 1, max: 100)
  end
end
