defmodule Remedy.Schema.Reference do
  @moduledoc """
  Reference Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          message: Message.t(),
          channel: Channel.t(),
          guild: Guild.t()
        }

  @primary_key false
  embedded_schema do
    belongs_to :message, Message
    belongs_to :channel, Channel
    belongs_to :guild, Guild
  end
end
