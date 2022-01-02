defmodule Remedy.Schema.GuildFeatures do
  use Remedy.Flag

  defstruct ANIMATED_ICON: 1 <<< 0,
            BANNER: 1 <<< 1,
            COMMERCE: 1 <<< 2,
            COMMUNITY: 1 <<< 3,
            DISCOVERABLE: 1 <<< 4,
            FEATURABLE: 1 <<< 5,
            INVITE_SPLASH: 1 <<< 6,
            MEMBER_VERIFICATION_GATE_ENABLED: 1 <<< 7,
            MONETIZATION_ENABLED: 1 <<< 8,
            MORE_STICKERS: 1 <<< 9,
            NEWS: 1 <<< 10,
            PARTNERED: 1 <<< 11,
            PREVIEW_ENABLED: 1 <<< 12,
            PRIVATE_THREADS: 1 <<< 13,
            ROLE_ICONS: 1 <<< 14,
            SEVEN_DAY_THREAD_ARCHIVE: 1 <<< 15,
            THREE_DAY_THREAD_ARCHIVE: 1 <<< 16,
            VANITY_URL: 1 <<< 17,
            VERIFIED: 1 <<< 18,
            VIP_REGIONS: 1 <<< 19,
            WELCOME_SCREEN_ENABLED: 1 <<< 20
end
