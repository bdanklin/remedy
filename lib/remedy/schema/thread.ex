defmodule Remedy.Schema.Thread do
  @moduledoc """
  Discord Thread Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          guild_id: Snowflake.t(),
          last_message_id: Snowflake.t(),
          member_count: integer(),
          message_count: integer(),
          name: String.t(),
          owner_id: Snowflake.t(),
          parent_id: Snowflake.t(),
          permission_overwrites: [PermissionOverwrite.t()],
          rate_limit_per_user: integer(),
          thread_metadata: ThreadMetadata.t(),
          type: integer()
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "channels" do
    field :guild_id, Snowflake
    field :owner_id, Snowflake
    field :parent_id, Snowflake

    field :last_message_id, Snowflake
    field :member_count, :integer
    field :message_count, :integer
    field :name, :string
    field :rate_limit_per_user, :integer
    field :type, :integer

    embeds_many :permission_overwrites, PermissionOverwrite
    embeds_one :thread_metadata, ThreadMetadata, on_replace: :update
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model -> cast_embed(cast_model, embed) end)
  end
end

defmodule Remedy.Schema.ThreadMember do
  @moduledoc """
  Thread Member Object
  """
  use Remedy.Schema
  alias Remedy.ISO8601

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

    cast(model, params, fields -- embeds)
  end
end
