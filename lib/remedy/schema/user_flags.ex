defmodule Remedy.Schema.UserFlags do
  use Remedy.Flag

  defstruct DISCORD_EMPLOYEE: 1 <<< 0,
            PARTNERED_SERVER_OWNER: 1 <<< 1,
            HYPESQUAD_EVENTS: 1 <<< 2,
            BUG_HUNTER_LEVEL_1: 1 <<< 3,
            HYPESQUAD_BRAVERY: 1 <<< 6,
            HYPESQUAD_BRILLIANCE: 1 <<< 7,
            HYPESQUAD_BALANCE: 1 <<< 8,
            EARLY_NITRO_SUPPORTER: 1 <<< 9,
            TEAM_PSEUDO_USER: 1 <<< 10,
            SYSTEM: 1 <<< 12,
            BUG_HUNTER_LEVEL_2: 1 <<< 14,
            VERIFIED_BOT: 1 <<< 16,
            VERIFIED_DEVELOPER: 1 <<< 17,
            CERTIFIED_MODERATOR: 1 <<< 18,
            BOT_HTTP_INTERACTIONS: 1 <<< 19,
            # SPAMMER UNDOCUMENTED: https://discord.com/channels/81384788765712384/381887113391505410/936018294916399134
            SPAMMER: 1 <<< 20
end
