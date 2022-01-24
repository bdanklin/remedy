defmodule Remedy.Schema.AuditLog do
  @moduledoc """
  Audit Log Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          audit_log_entries: [AuditLogEntry.t()],
          guild_scheduled_events: [Event.t()],
          integrations: [Integration.t()],
          threads: [Thread.t()],
          users: [User.t()],
          webhooks: [Webhook.t()]
        }

  @primary_key false
  embedded_schema do
    embeds_many :audit_log_entries, AuditLogEntry
    embeds_many :guild_scheduled_events, Event
    embeds_many :webhooks, Webhook
    embeds_many :users, User
    embeds_many :integrations, Integration
    embeds_many :threads, Channel
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [])
    |> cast_embed(:audit_log_entries)
    |> cast_embed(:guild_scheduled_events)
    |> cast_embed(:webhooks)
    |> cast_embed(:users)
    |> cast_embed(:integrations)
    |> cast_embed(:threads)
  end
end
