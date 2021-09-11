defmodule Remedy.Schema.AuditLog do
  @moduledoc false
  use Remedy.Schema
  @primary_key false

  embedded_schema do
    belongs_to :guild, Guild
    embeds_many :webhooks, Webhook
    embeds_many :users, User
    embeds_many :audit_log_entries, AuditLogEntry
    embeds_many :integrations, Integration
    embeds_many :threads, Channel
  end
end

defmodule Remedy.Schema.AuditLogEntry do
  @moduledoc false
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :target_id, :string
    field :action_type, :integer
    field :reason, :string
    belongs_to :user, User
    embeds_many :options, AuditLogOption
    embeds_many :changes, Change
  end
end

defmodule Remedy.Schema.AuditLogOption do
  @moduledoc false
  use Remedy.Schema

  @primary_key false
  embedded_schema do
    field :delete_member_days, :string
    field :members_removed, :string
    belongs_to :channel, Channel
    field :message_id, Snowflake
    field :count, :string
    field :id, Snowflake
    embeds_one :overwrite, PermissionOverwrite
    field :type, :string
    field :role_name, :string
  end
end

defmodule Remedy.Schema.AuditLogChange do
  @moduledoc false
  use Remedy.Schema

  @primary_key false
  embedded_schema do
    field :new_value, :any, virtual: true
    field :old_value, :any, virtual: true
    field :key, :any, virtual: true
  end
end
