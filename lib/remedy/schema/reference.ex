defmodule Remedy.Schema.Reference do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key false

  embedded_schema do
    belongs_to :message, Message
    belongs_to :channel, Channel
    belongs_to :guild, Guild
  end
end
