defmodule Remedy.Gateway.Dispatch.SpeakingUpdate do
  @moduledoc false
  use Remedy.Schema
  alias Remedy.Cache

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
  @type timed_out :: boolean()

  @type t :: %__MODULE__{
          channel_id: channel_id,
          guild_id: guild_id,
          speaking: speaking,
          timed_out: timed_out
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :speaking, :boolean
    field :timed_out, :boolean
  end

  def handle({event, payload, socket}) do
    {event, new(payload), socket}
  end
end
