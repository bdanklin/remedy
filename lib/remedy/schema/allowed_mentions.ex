defmodule Remedy.Schema.AllowedMentions do
  use Remedy.Schema

  embedded_schema do
    field :parse, {:array, :string}
    field :replied_user, :boolean
    field :roles, {:array, Snowflake}
    field :users, {:array, Snowflake}
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:replied_user, :parse, :roles, :users])
    |> validate_inclusion(:parse, ["roles", "users", "everyone"])
  end
end
