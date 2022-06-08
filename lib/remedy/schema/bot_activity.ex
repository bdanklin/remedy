defmodule Remedy.Schema.BotActivity do
  use Remedy.Schema

  embedded_schema do
    field :name, :string
    field :type, ActivityType
    field :url, URL
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [:name, :type, :url])
  end
end
