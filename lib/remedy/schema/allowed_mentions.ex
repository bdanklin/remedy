defmodule Remedy.Schema.AllowedMentions do
  @moduledoc """
  Allowed Mentions Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          parse: [String.t()],
          replied_user: boolean(),
          roles: [Snowflake.t()],
          users: [Snowflake.t()]
        }

  @primary_key false
  embedded_schema do
    field :parse, {:array, :string}, default: nil
    field :replied_user, :boolean, default: nil
    field :roles, {:array, Snowflake}, default: nil
    field :users, {:array, Snowflake}, default: nil
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:replied_user, :parse, :roles, :users])
  end
end
