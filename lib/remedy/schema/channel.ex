defmodule Remedy.Schema.Channel do
  @moduledoc """
  Discord Channel Object
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
          #       application_id: integer(),
          last_pin_timestamp: String.t(),
          rtc_region: String.t(),
          video_quality_mode: integer(),
          message_count: integer(),
          member_count: integer(),
          default_auto_archive_duration: integer(),
          permissions: String.t(),
          parent: Channel.t(),
          #     owner: User.t(),
          guild: Guild.t(),
          permission_overwrites: [overwrite]
          #    messages: [Message.t()]
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "channels" do
    field :type, :integer
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

    belongs_to :parent, Channel
    #  belongs_to :owner, User
    belongs_to :guild, Guild
    embeds_many :permission_overwrites, PermissionOverwrite

    #  has_many :messages, Message

    timestamps()
  end

  @doc false
  def form(params), do: params |> changeset() |> apply_changes()
  @doc false
  def shape(model, params), do: model |> changeset(params) |> apply_changes()

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
