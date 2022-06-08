defmodule Remedy.Gateway.Commands.RequestGuildMembers do
  @moduledoc false
  #############################################################################
  ## 8
  ## Request Guild Members
  ## Send
  ## Request information about offline guild members in a large guild.

  use Remedy.Schema

  embedded_schema do
    field :guild_id, Snowflake
    field :query, :string, default: ""
    field :limit, :integer
    field :presences, :boolean
    field :user_ids, {:array, Snowflake}
    field :nonce, :binary
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [:guild_id, :query, :limit, :presences, :user_ids, :nonce])
    |> validate_required([:guild_id, :limit])
  end

  def send(_socket, opts) do
    opts
    |> changeset()
  end
end
