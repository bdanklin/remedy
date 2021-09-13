defmodule Remedy.Gateway.Events.RequestGuildMembers do
  @moduledoc false
  use Remedy.Gateway.Payload

  embedded_schema do
    field :guild_id, :integer
    field :query, :integer
    field :limit, :boolean, default: false
  end

  defp payload(socket, %{guild_id: _guild_id, query: _query} = opts) do
    {%__MODULE__{
       guild_id: opts.guild_id,
       query: opts.query,
       limit: opts.limit || false
     }, socket}
  end
end
