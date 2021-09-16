defmodule Remedy.Schema.Channel do
  @moduledoc """
  Discord Channel Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: integer(),
          position: integer(),
          name: String.t(),
          topic: String.t(),
          nsfw: boolean(),
          last_message_id: integer(),
          bitrate: integer(),
          user_limit: integer(),
          rate_limit_per_user: integer(),
          icon: String.t(),
          application_id: integer(),
          last_pin_timestamp: String.t(),
          rtc_region: String.t(),
          video_quality_mode: integer(),
          message_count: integer(),
          member_count: integer(),
          default_auto_archive_duration: integer(),
          permissions: String.t(),
          parent: Channel.t(),
          owner: User.t(),
          guild: Guild.t(),
          permission_overwrites: [PermissionOverwrite.t()],
          member: ThreadMember.t(),
          thread_metadata: ThreadMetadata.t(),
          messages: [Message.t()]
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "channels" do
    field :type, :integer
    field :position, :integer
    field :name, :string
    field :topic, :string
    field :nsfw, :boolean
    field :last_message_id, :integer
    field :bitrate, :integer
    field :user_limit, :integer
    field :rate_limit_per_user, :integer
    field :icon, :string
    field :application_id, :integer
    field :last_pin_timestamp, :string
    field :rtc_region, :string
    field :video_quality_mode, :integer
    field :message_count, :integer
    field :member_count, :integer
    field :default_auto_archive_duration, :integer
    field :permissions, :string

    belongs_to :parent, Channel
    belongs_to :owner, User
    belongs_to :guild, Guild
    embeds_many :permission_overwrites, PermissionOverwrite
    embeds_one :member, ThreadMember
    embeds_one :thread_metadata, ThreadMetadata

    has_many :messages, Message
  end
end
