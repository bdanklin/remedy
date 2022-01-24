defmodule Remedy.Schema.AuditLogOption do
  @moduledoc """
  Discord Audit Log Option Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          channel_id: Snowflake.t(),
          count: String.t(),
          delete_member_days: String.t(),
          id: Snowflake,
          members_removed: integer(),
          message_id: Snowflake.t(),
          role_name: String.t(),
          type: AuditLogOptionType.t()
        }

  @primary_key false
  embedded_schema do
    field :channel_id, Snowflake
    field :count, :string
    field :delete_member_days, :string
    field :id, Snowflake
    field :members_removed, :string
    field :message_id, Snowflake
    field :role_name, :string
    field :type, AuditLogOptionType
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)

    model
    |> cast(params, fields -- embeds)
  end
end
