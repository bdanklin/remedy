defmodule Remedy.Schema.AuditLogOption do
  @moduledoc """
  Discord Audit Log Option Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake,
          message_id: Snowflake.t(),
          channel_id: Snowflake.t(),
          members_removed: String.t(),
          delete_member_days: String.t(),
          count: String.t(),
          type: AuditLogOptionType.t(),
          role_name: String.t(),
          #    channel: Channel.t(),
          overwrite: PermissionOverwrite.t()
        }

  @primary_key false
  embedded_schema do
    field :id, Snowflake
    field :message_id, Snowflake
    field :channel_id, Snowflake
    field :members_removed, :string
    field :delete_member_days, :string
    field :count, :string
    field :type, AuditLogOptionType
    field :role_name, :string
    # belongs_to :channel, Channel
    embeds_one :overwrite, PermissionOverwrite
  end

  @doc false
  def form(params), do: changeset(params) |> apply_changes()

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
