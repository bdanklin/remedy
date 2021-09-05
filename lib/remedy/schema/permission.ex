defmodule Remedy.Schema.Permission do
  @moduledoc false
  use Remedy.Schema, :model
  use BattleStandard

  @type t :: %__MODULE__{
          CREATE_INSTANT_INVITE: boolean(),
          KICK_MEMBERS: boolean(),
          BAN_MEMBERS: boolean(),
          ADMINISTRATOR: boolean(),
          MANAGE_CHANNELS: boolean(),
          MANAGE_GUILD: boolean(),
          ADD_REACTIONS: boolean(),
          VIEW_AUDIT_LOG: boolean(),
          PRIORITY_SPEAKER: boolean(),
          STREAM: boolean(),
          VIEW_CHANNEL: boolean(),
          SEND_MESSAGES: boolean(),
          SEND_TTS_MESSAGES: boolean(),
          MANAGE_MESSAGES: boolean(),
          EMBED_LINKS: boolean(),
          ATTACH_FILES: boolean(),
          READ_MESSAGE_HISTORY: boolean(),
          MENTION_EVERYONE: boolean(),
          USE_EXTERNAL_EMOJIS: boolean(),
          VIEW_GUILD_INSIGHTS: boolean(),
          CONNECT: boolean(),
          SPEAK: boolean(),
          MUTE_MEMBERS: boolean(),
          DEAFEN_MEMBERS: boolean(),
          MOVE_MEMBERS: boolean(),
          USE_VAD: boolean(),
          CHANGE_NICKNAME: boolean(),
          MANAGE_NICKNAMES: boolean(),
          MANAGE_ROLES: boolean(),
          MANAGE_WEBHOOKS: boolean(),
          MANAGE_EMOJIS_AND_STICKERS: boolean(),
          USE_APPLICATION_COMMANDS: boolean(),
          REQUEST_TO_SPEAK: boolean(),
          MANAGE_THREADS: boolean(),
          USE_PUBLIC_THREADS: boolean(),
          USE_PRIVATE_THREADS: boolean(),
          USE_EXTERNAL_STICKERS: boolean()
        }

  embedded_schema do
    field :CREATE_INSTANT_INVITE, :boolean, default: false
    field :KICK_MEMBERS, :boolean, default: false
    field :BAN_MEMBERS, :boolean, default: false
    field :ADMINISTRATOR, :boolean, default: false
    field :MANAGE_CHANNELS, :boolean, default: false
    field :MANAGE_GUILD, :boolean, default: false
    field :ADD_REACTIONS, :boolean, default: false
    field :VIEW_AUDIT_LOG, :boolean, default: false
    field :PRIORITY_SPEAKER, :boolean, default: false
    field :STREAM, :boolean, default: false
    field :VIEW_CHANNEL, :boolean, default: false
    field :SEND_MESSAGES, :boolean, default: false
    field :SEND_TTS_MESSAGES, :boolean, default: false
    field :MANAGE_MESSAGES, :boolean, default: false
    field :EMBED_LINKS, :boolean, default: false
    field :ATTACH_FILES, :boolean, default: false
    field :READ_MESSAGE_HISTORY, :boolean, default: false
    field :MENTION_EVERYONE, :boolean, default: false
    field :USE_EXTERNAL_EMOJIS, :boolean, default: false
    field :VIEW_GUILD_INSIGHTS, :boolean, default: false
    field :CONNECT, :boolean, default: false
    field :SPEAK, :boolean, default: false
    field :MUTE_MEMBERS, :boolean, default: false
    field :DEAFEN_MEMBERS, :boolean, default: false
    field :MOVE_MEMBERS, :boolean, default: false
    field :USE_VAD, :boolean, default: false
    field :CHANGE_NICKNAME, :boolean, default: false
    field :MANAGE_NICKNAMES, :boolean, default: false
    field :MANAGE_ROLES, :boolean, default: false
    field :MANAGE_WEBHOOKS, :boolean, default: false
    field :MANAGE_EMOJIS_AND_STICKERS, :boolean, default: false
    field :USE_APPLICATION_COMMANDS, :boolean, default: false
    field :REQUEST_TO_SPEAK, :boolean, default: false
    field :MANAGE_THREADS, :boolean, default: false
    field :USE_PUBLIC_THREADS, :boolean, default: false
    field :USE_PRIVATE_THREADS, :boolean, default: false
    field :USE_EXTERNAL_STICKERS, :boolean, default: false
  end

  @flag_bits [
    {:CREATE_INSTANT_INVITE, 1 <<< 0},
    {:KICK_MEMBERS, 1 <<< 1},
    {:BAN_MEMBERS, 1 <<< 2},
    {:ADMINISTRATOR, 1 <<< 3},
    {:MANAGE_CHANNELS, 1 <<< 4},
    {:MANAGE_GUILD, 1 <<< 5},
    {:ADD_REACTIONS, 1 <<< 6},
    {:VIEW_AUDIT_LOG, 1 <<< 7},
    {:PRIORITY_SPEAKER, 1 <<< 8},
    {:STREAM, 1 <<< 9},
    {:VIEW_CHANNEL, 1 <<< 10},
    {:SEND_MESSAGES, 1 <<< 11},
    {:SEND_TTS_MESSAGES, 1 <<< 12},
    {:MANAGE_MESSAGES, 1 <<< 13},
    {:EMBED_LINKS, 1 <<< 14},
    {:ATTACH_FILES, 1 <<< 15},
    {:READ_MESSAGE_HISTORY, 1 <<< 16},
    {:MENTION_EVERYONE, 1 <<< 17},
    {:USE_EXTERNAL_EMOJIS, 1 <<< 18},
    {:VIEW_GUILD_INSIGHTS, 1 <<< 19},
    {:CONNECT, 1 <<< 20},
    {:SPEAK, 1 <<< 21},
    {:MUTE_MEMBERS, 1 <<< 22},
    {:DEAFEN_MEMBERS, 1 <<< 23},
    {:MOVE_MEMBERS, 1 <<< 24},
    {:USE_VAD, 1 <<< 25},
    {:CHANGE_NICKNAME, 1 <<< 26},
    {:MANAGE_NICKNAMES, 1 <<< 27},
    {:MANAGE_ROLES, 1 <<< 28},
    {:MANAGE_WEBHOOKS, 1 <<< 29},
    {:MANAGE_EMOJIS_AND_STICKERS, 1 <<< 30},
    {:USE_APPLICATION_COMMANDS, 1 <<< 31},
    {:REQUEST_TO_SPEAK, 1 <<< 32},
    {:MANAGE_THREADS, 1 <<< 34},
    {:USE_PUBLIC_THREADS, 1 <<< 35},
    {:USE_PRIVATE_THREADS, 1 <<< 36},
    {:USE_EXTERNAL_STICKERS, 1 <<< 37}
  ]
end
