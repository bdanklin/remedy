defmodule Remedy.Gateway.Events.Ready do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :v, :integer
    field :session_id, :string
    field :shard, {:array, :integer}
    embeds_one :application, App
    embeds_one :user, User
    embeds_many :guilds, Guild
  end
end
