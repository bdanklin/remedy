defmodule Remedy.Schema.Channel do
  @moduledoc """
  Discord Channel Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: ChannelType.t(),
          position: integer(),
          name: String.t(),
          topic: String.t(),
          nsfw: boolean(),
          last_message_id: integer(),
          bitrate: integer(),
          user_limit: integer(),
          rate_limit_per_user: integer(),
          icon: String.t(),
          #       application_id: integer(),
          last_pin_timestamp: String.t(),
          rtc_region: String.t(),
          video_quality_mode: integer(),
          message_count: integer(),
          member_count: integer(),
          default_auto_archive_duration: integer(),
          permissions: String.t(),
          parent_id: Snowflake.t(),
          #     owner: User.t(),
          guild_id: Snowflake.t(),
          permission_overwrites: [PermissionOverwrite.t()]
          #    messages: [Message.t()]
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "channels" do
    field :type, ChannelType
    field :position, :integer
    field :name, :string
    field :topic, :string
    field :nsfw, :boolean
    field :last_message_id, Snowflake
    field :bitrate, :integer
    field :user_limit, :integer
    field :rate_limit_per_user, :integer
    field :icon, :string
    #   field :application_id, :integer
    field :last_pin_timestamp, :string
    field :rtc_region, :string
    field :video_quality_mode, :integer
    field :message_count, :integer
    field :member_count, :integer
    field :default_auto_archive_duration, :integer
    field :permissions, :string

    field :parent_id, Snowflake
    #  belongs_to :owner, User
    field :guild_id, Snowflake
    embeds_many :permission_overwrites, PermissionOverwrite, on_replace: :delete

    #  has_many :messages, Message
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
