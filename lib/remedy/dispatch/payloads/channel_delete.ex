defmodule Remedy.Dispatch.Payloads.ChannelDelete do
  @moduledoc false
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :guild_id, Snowflake
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:id, :guild_id])
    |> validate_required([:id])
  end
end
