defmodule Remedy.Schema.Ban do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key false

  schema "bans" do
    belongs_to :user, User
    belongs_to :guild, Guild
    field :reason, :string
  end
end
