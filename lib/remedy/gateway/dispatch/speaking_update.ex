defmodule Remedy.Gateway.Dispatch.SpeakingUpdate do
  @moduledoc """
  Struct representing a Remedy-generated Speaking Update event

  Remedy will generate this event when the bot starts or stops playing audio.
  """

  defstruct [
    :channel_id,
    :guild_id,
    :speaking,
    :timed_out
  ]

  alias Remedy.Struct.{Channel, Guild}

  @typedoc """
  Id of the channel this speaking update is occurring in.
  """
  @type channel_id :: Channel.id()

  @typedoc """
  Id of the guild this speaking update is occurring in.
  """
  @type guild_id :: Guild.id()

  @typedoc """
  Boolean representing if bot has started or stopped speaking.
  """
  @type speaking :: boolean()

  @typedoc """
  Boolean representing if speaking update was caused by an audio timeout.
  """
  @typedoc since: "0.5.0"
  @type timed_out :: boolean()

  @type t :: %__MODULE__{
          channel_id: channel_id,
          guild_id: guild_id,
          speaking: speaking,
          timed_out: timed_out
        }

  @doc false
  def to_struct(map), do: struct(__MODULE__, map)
end
