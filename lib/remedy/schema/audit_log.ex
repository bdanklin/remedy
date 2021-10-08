defmodule Remedy.Schema.AuditLog do
  @moduledoc """
  Discord Audit Log Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          guild: Guild.t(),
          webhooks: [Webhook.t()],
          users: [User.t()],
          audit_log_entries: [AuditLogEntry.t()],
          integrations: [Integration.t()],
          threads: [Thread.t()]
        }

  @primary_key false
  embedded_schema do
    belongs_to :guild, Guild
    embeds_many :webhooks, Webhook
    embeds_many :users, User
    embeds_many :audit_log_entries, AuditLogEntry
    embeds_many :integrations, Integration
    embeds_many :threads, Channel
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> apply_changes()
  end

  @doc false
  def update(model, params) do
    model
    |> changeset(params)
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
