defmodule Remedy.Schema.AuditLog do
  @moduledoc """
  Discord Audit Log Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          webhooks: [Webhook.t()],
          users: [User.t()],
          audit_log_entries: [AuditLogEntry.t()],
          integrations: [Integration.t()],
          threads: [Thread.t()]
        }

  @primary_key false
  embedded_schema do
    field :guild_id, Snowflake
    embeds_many :webhooks, Webhook
    embeds_many :users, User
    embeds_many :audit_log_entries, AuditLogEntry
    embeds_many :integrations, Integration
    embeds_many :threads, Channel
  end

  @doc false
  def form(params), do: changeset(params) |> apply_changes()
  @doc false
  def shape(model, params), do: changeset(model, params) |> apply_changes()

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:guild_id])
    |> cast_embed(:webhooks)
    |> cast_embed(:users)
    |> cast_embed(:audit_log_entries)
    |> cast_embed(:integrations)
    |> cast_embed(:threads)
  end
end

defmodule Remedy.Schema.AuditLogEntry do
  @moduledoc """
  Discord Audit Log Entry Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          target_id: String.t(),
          action_type: integer(),
          reason: String.t(),
          user: User.t(),
          options: [AuditLogOption.t()],
          changes: [map()]
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :target_id, :string
    field :action_type, :integer
    field :reason, :string
    field :changes, {:array, :map}
    belongs_to :user, User
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
