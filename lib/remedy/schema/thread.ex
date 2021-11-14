defmodule Remedy.Schema.Thread do
  @moduledoc """
  Discord Thread Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          #    application_id: integer(),
          #    bitrate: integer(),
          #    default_auto_archive_duration: integer(),
          #    icon: String.t(),
          #    last_pin_timestamp: String.t(),
          #    member: ThreadMember.t(),
          #    messages: [Message.t()]
          #    permissions: String.t(),
          #    position: integer(),
          #    rtc_region: String.t(),
          #    topic: String.t(),
          #    user_limit: integer(),
          #    video_quality_mode: integer(),
          #    guild: Guild.t(),
          last_message_id: Snowflake.t(),
          member_count: integer(),
          message_count: integer(),
          name: String.t(),
          #  owner: User.t(),
          #  parent: Channel.t(),
          permission_overwrites: [PermissionOverwrite.t()],
          rate_limit_per_user: integer(),
          thread_metadata: ThreadMetadata.t(),
          type: integer(),
          guild_id: Snowflake.t(),
          owner_id: Snowflake.t(),
          parent_id: Snowflake.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "channels" do
    # belongs_to :guild, Guild
    # belongs_to :owner, User
    # belongs_to :parent, Channel

    field :guild_id, Snowflake
    field :owner_id, Snowflake
    field :parent_id, Snowflake

    field :last_message_id, Snowflake
    field :member_count, :integer
    field :message_count, :integer
    field :name, :string
    field :rate_limit_per_user, :integer
    field :type, :integer

    # field :position, :integer
    # field :topic, :string
    # field :bitrate, :integer
    # field :user_limit, :integer
    # field :icon, :string
    # field :application_id, :integer
    # field :last_pin_timestamp, :string
    # field :rtc_region, :string
    # field :video_quality_mode, :integer
    # field :default_auto_archive_duration, :integer
    # field :permissions, :string

    embeds_many :permission_overwrites, PermissionOverwrite
    embeds_one :thread_metadata, ThreadMetadata

    #  has_many :messages, Message
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
  schema "thread_members" do
    field :user_id, Snowflake
    field :join_timestamp, ISO8601
    field :flags, :integer
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:id, :user_id, :join_timestamp, :flags])
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
