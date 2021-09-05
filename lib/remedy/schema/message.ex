defmodule Remedy.Schema.Message do
  @moduledoc false
  use Remedy.Schema, :model

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "messages" do
    #   belongs_to :message_reference,
    #   belongs_to :referenced_message,
    belongs_to :application, App
    belongs_to :author, User, foreign_key: :author_id
    belongs_to :channel, Channel
    belongs_to :guild, Guild
    belongs_to :member, Member
    belongs_to :thread, Channel
    belongs_to :webhook, Webhook
    embeds_many :attachments, Attachments
    embeds_many :embeds, Embed
    embeds_many :mention_roles, Role
    embeds_many :sticker_items, Sticker
    embeds_one :interaction, Interaction
    field :content, :string
    field :edited_timestamp, ISO8601
    field :flags, :integer
    field :mention_everyone, :boolean
    field :nonce, :integer
    field :pinned, :boolean
    field :timestamp, ISO8601
    field :tts, :boolean
    field :type, :integer
    has_many :components, Component
    has_many :mention_channels, Channel
    has_many :mentions, User
    has_many :reactions, Reaction
    has_one :activity, Activity
  end

  def link(%__MODULE__{guild_id: guild_id, channel_id: channel_id, id: id}) do
    "https://discord.com/channels/#{guild_id}/#{channel_id}/#{id}"
  end
end

defmodule Remedy.Schema.MessageFlags do
  @moduledoc false
  use Remedy.Schema, :model
  use BattleStandard

  @flag_bits [
    {:CROSSPOSTED, 1 <<< 0},
    {:IS_CROSSPOST, 1 <<< 1},
    {:SUPPRESS_EMBEDS, 1 <<< 2},
    {:SOURCE_MESSAGE_DELETED, 1 <<< 3},
    {:URGENT, 1 <<< 4},
    {:HAS_THREAD, 1 <<< 5},
    {:EPHEMERAL, 1 <<< 6},
    {:LOADING, 1 <<< 7}
  ]

  @type t :: %__MODULE__{
          CROSSPOSTED: boolean(),
          IS_CROSSPOST: boolean(),
          SUPPRESS_EMBEDS: boolean(),
          SOURCE_MESSAGE_DELETED: boolean(),
          URGENT: boolean(),
          HAS_THREAD: boolean(),
          EPHEMERAL: boolean(),
          LOADING: boolean()
        }

  embedded_schema do
    field :CROSSPOSTED, :boolean, default: false
    field :IS_CROSSPOST, :boolean, default: false
    field :SUPPRESS_EMBEDS, :boolean, default: false
    field :SOURCE_MESSAGE_DELETED, :boolean, default: false
    field :URGENT, :boolean, default: false
    field :HAS_THREAD, :boolean, default: false
    field :EPHEMERAL, :boolean, default: false
    field :LOADING, :boolean, default: false
  end
end
