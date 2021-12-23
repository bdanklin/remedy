defmodule Remedy.Schema.ApplicationFlags do
  use Remedy.Flag

  @moduledoc """

   VALUE	    | FLAG
   -------    | ---------------------------------------
   `1 << 12`	| `:GATEWAY_PRESENCE`
   `1 << 13`	| `:GATEWAY_PRESENCE_LIMITED`
   `1 << 14`	| `:GATEWAY_GUILD_MEMBERS`
   `1 << 15`	| `:GATEWAY_GUILD_MEMBERS_LIMITED`
   `1 << 16`	| `:VERIFICATION_PENDING_GUILD_LIMIT`
   `1 << 17`	| `:EMBEDDED`
   `1 << 18`	| `:GATEWAY_MESSAGE_CONTENT`
   `1 << 19`	| `:GATEWAY_MESSAGE_CONTENT_LIMITED`

  """

  defstruct GATEWAY_PRESENCE: 1 <<< 12,
            GATEWAY_PRESENCE_LIMITED: 1 <<< 13,
            GATEWAY_GUILD_MEMBERS: 1 <<< 14,
            GATEWAY_GUILD_MEMBERS_LIMITED: 1 <<< 15,
            VERIFICATION_PENDING_GUILD_LIMIT: 1 <<< 16,
            EMBEDDED: 1 <<< 17,
            GATEWAY_MESSAGE_CONTENT: 1 <<< 18,
            GATEWAY_MESSAGE_CONTENT_LIMITED: 1 <<< 19
end
