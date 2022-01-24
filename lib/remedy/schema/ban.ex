defmodule Remedy.Schema.Ban do
  @moduledoc """
  Ban Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          user_id: Snowflake.t(),
          guild_id: Snowflake.t(),
          reason: String.t(),
          invalid_since: DateTime.t()
        }

  embedded_schema do
    field :user_id, Snowflake
    field :guild_id, Snowflake
    field :reason, :string
    field :invalid_since, :utc_datetime, default: nil
  end

  @doc false

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:user_id, :guild_id, :reason])
    |> validate_required([:user_id, :guild_id])
  end
end
