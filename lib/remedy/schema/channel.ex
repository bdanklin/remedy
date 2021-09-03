defmodule Remedy.Schema.Channel do
  use Remedy.Schema, :model

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

    #   has_many :recipients, User

    belongs_to :guild, Guild

    embeds_many :permission_overwrites, PermissionOverwrite
    embeds_one :member, ThreadMember
    embeds_one :thread_metadata, ThreadMetadata
  end
end
