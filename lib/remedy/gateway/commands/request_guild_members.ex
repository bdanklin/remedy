defmodule Remedy.Gateway.Commands.RequestGuildMembers do
  @moduledoc false

  use Remedy.Schema

  embedded_schema do
    field :guild_id, Snowflake
    field :query, :string
    field :limit, :integer
  end

  def send(_socket, opts) do
    %__MODULE__{
      guild_id: opts[:guild_id],
      query: opts[:query],
      limit: opts[:limit] || false
    }
  end
end
