defmodule Remedy.Schema.WebhookType do
  use Remedy.Type
  defstruct INCOMING: 1, CHANNEL_FOLLOWER: 2, APPLICATION: 3
end
