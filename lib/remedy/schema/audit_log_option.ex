defmodule Remedy.Schema.AuditLogOption do
  @moduledoc """
  Discord Audit Log Option Object
  """
  use Remedy.Schema
  @type overwrite :: PermissionOverwrite.t()

  @type t :: %__MODULE__{
          delete_member_days: String.t(),
          members_removed: String.t(),
          channel: Channel.t(),
          message_id: Snowflake.t(),
          count: String.t(),
          id: Snowflake,
          overwrite: overwrite,
          type: String.t(),
          role_name: String.t()
        }

  @primary_key false
  embedded_schema do
    field :delete_member_days, :string
    field :members_removed, :string
    field :message_id, Snowflake
    field :count, :string
    field :id, Snowflake
    field :type, :string
    field :role_name, :string
    belongs_to :channel, Channel
    embeds_one :overwrite, PermissionOverwrite
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> apply_changes()
  end

  @doc false
  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
