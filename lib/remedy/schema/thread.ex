defmodule Remedy.Schema.Thread do
  @moduledoc """
  Discord Thread Object
  """
  use Remedy.Schema
  @type overwrite :: PermissionOverwrite.t()
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
          permission_overwrites: [overwrite],
          member: ThreadMember.t(),
          thread_metadata: ThreadMetadata.t(),
          messages: [Message.t()]
        }

  @primary_key {:id, :id, autogenerate: false}
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

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end

defmodule Remedy.Schema.ThreadMember do
  @moduledoc """
  Thread Member Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          user_id: Snowflake.t(),
          join_timestamp: ISO8601.t(),
          flags: integer()
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :user_id, Snowflake
    field :join_timestamp, ISO8601
    field :flags, :integer
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

defmodule Remedy.Schema.ThreadMetadata do
  @moduledoc """
  Thread Metadata Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          archived: boolean(),
          auto_archive_duration: integer(),
          archive_timestamp: ISO8601.t(),
          locked: boolean(),
          invitable: boolean()
        }

  @primary_key false
  embedded_schema do
    field :archived, :boolean
    field :auto_archive_duration, :integer
    field :archive_timestamp, ISO8601
    field :locked, :boolean
    field :invitable, :boolean
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
