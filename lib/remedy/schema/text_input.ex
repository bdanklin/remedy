defmodule Remedy.Schema.TextInput do
  use Remedy.Schema

  embedded_schema do
    field :type, :integer, default: 4
    field :custom_id, :string
    field :style, TextInputStyle
    field :label, :string
    field :min_length, :integer
    field :max_length, :integer
    field :required, :boolean
    field :value, :string
    field :placeholder, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [:custom_id, :style, :label, :min_length, :max_length, :value, :placeholder, :required])
    |> validate_required([:type, :custom_id, :style, :label])
  end
end
