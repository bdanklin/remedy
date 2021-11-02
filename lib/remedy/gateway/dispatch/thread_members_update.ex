defmodule Remedy.Gateway.Dispatch.ThreadMembersUpdate do
  @moduledoc false
  alias Remedy.Schema.Channel

  def handle({event, payload, socket}) do
    {event, Channel.new(payload), socket}
  end

  @moduledoc """
  Thread Members Update
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake,
          member_count: integer(),
          removed_members: [Snowflake],
          guild_id: Snowflake,
          added_members: Snowflake
        }

  @primary_key false
  embedded_schema do
    field :id, Snowflake
    field :member_count, :integer
    field :removed_members, {:array, Snowflake}
    field :guild_id, Snowflake
    embeds_many :added_members, ThreadMember
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
