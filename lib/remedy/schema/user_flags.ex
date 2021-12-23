defmodule Remedy.Schema.UserFlags do
  @moduledoc """
  User Flags

  """
  use Remedy.Flag

  defstruct DISCORD_EMPLOYEE: 1 <<< 0,
            PARTNERED_SERVER_OWNER: 1 <<< 1,
            HYPESQUAD_EVENTS: 1 <<< 2,
            BUG_HUNTER_LEVEL_1: 1 <<< 3,
            HYPESQUAD_BRAVERY: 1 <<< 6,
            HYPESQUAD_BRILLIANCE: 1 <<< 7,
            HYPESQUAD_BALANCE: 1 <<< 8,
            EARLY_SUPPORTER: 1 <<< 9,
            TEAM_USER: 1 <<< 10,
            SYSTEM: 1 <<< 12,
            BUG_HUNTER_LEVEL_2: 1 <<< 14,
            VERIFIED_BOT: 1 <<< 16,
            VERIFIED_DEVELOPER: 1 <<< 17,
            DISCORD_CERTIFIED_MODERATOR: 1 <<< 18
end
