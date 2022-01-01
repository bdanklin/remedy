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
