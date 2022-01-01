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

  @primary_key {:id, Snowflake, autogenerate: false}
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
