defmodule Remedy.Schema.Ban do
  @moduledoc """
  Discord Ban Object
  """
  use Remedy.Schema
  @primary_key false

  embedded_schema do
    belongs_to :user, User
    belongs_to :guild, Guild
    field :reason, :string
  end
end
