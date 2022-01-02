defmodule Remedy.Schema.ThreadMember do
  @moduledoc """
  Thread Member Object
  """
  use Remedy.Schema
  alias Remedy.ISO8601

  @type t :: %__MODULE__{
          user_id: Snowflake.t(),
          join_timestamp: ISO8601.t(),
          flags: ThreadMemberFlags.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "thread_members" do
    field :user_id, Snowflake
    field :join_timestamp, ISO8601
    field :flags, ThreadMemberFlags
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:id, :user_id, :join_timestamp, :flags])
  end
end
