defmodule Remedy.Schema.AuditLogEntry do
  @moduledoc """
  Discord Audit Log Event Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          target_id: String.t(),
          action_type: AuditLogActionType.t(),
          reason: String.t(),
          user_id: Snowflake.t(),
          user: User.t(),
          options: [AuditLogOption.t()],
          changes: [map()]
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :target_id, Snowflake
    field :user_id, Snowflake
    field :action_type, AuditLogActionType
    field :reason, :string
    field :changes, {:array, :map}
    embeds_one :user, User
    embeds_many :options, AuditLogOption
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
