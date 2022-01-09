defmodule Remedy.Schema.Event do
  @moduledoc """
  Event Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          guild_id: Snowflake.t(),
          channel_id: Snowflake.t() | nil,
          creator_id: Snowflake.t() | nil,
          name: String.t(),
          description: String.t() | nil,
          scheduled_start_time: ISO8601.t(),
          scheduled_end_time: ISO8601.t(),
          privacy_level: EventPrivacyLevel.t(),
          status: EventStatus.t(),
          entity_type: EventEntityType.t(),
          entity_id: Snowflake.t(),
          entity_metadata: EventEntityMetadata.t(),
          creator: User.t() | nil,
          user_count: integer() | nil
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :creator_id, Snowflake
    field :name, :string
    field :description, :string
    field :scheduled_start_time, ISO8601
    field :scheduled_end_time, ISO8601
    field :privacy_level, EventPrivacyLevel
    field :status, EventStatus
    field :entity_type, EventEntityType
    field :entity_id, Snowflake
    embeds_one :entity_metadata, EventEntityMetadata
    embeds_one :creator, User
    field :user_count, :integer
  end
end
