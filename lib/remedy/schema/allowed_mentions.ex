defmodule Remedy.Schema.AllowedMentions do
  @moduledoc """
  Discord Allowed Mentions Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          parse: [String.t()],
          replied_user: boolean(),
          roles: [Snowflake.t()],
          users: [Snowflake.t()]
        }

  @type c :: t | %{}

  embedded_schema do
    field :parse, Ecto.Enum, values: [:roles, :users, :everyone]
    field :replied_user, :boolean
    field :roles, {:array, Snowflake}
    field :users, {:array, Snowflake}
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:replied_user, :parse, :roles, :users])
  end
end
