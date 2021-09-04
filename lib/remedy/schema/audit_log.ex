# defmodule Remedy.Schema.AuditLog do
# use Remedy.Schema, :model

# schema "audit_logs" do
# belongs_to :guild, Guild
# has_many :webhooks, Webhook
# has_many :users, User
# has_many :audit_log_entries, Entry
# has_many :integrations, Integration
# has_many :threads, Channel
# end
# end

# defmodule Remedy.Schema.AuditLog.Entry do
# use Remedy.Schema, :model
# alias Remedy.Schema.AuditLog.Change

# @primary_key {:id, :id, autogenerate: false}
# schema "audit_logs" do
# field :target_id, :string
# embeds_many :changes, Change
# belongs_to :user, User
# field :action_type, :integer
# field :options, AuditLog.Option
# field :reason, :string
# end
# end

# defmodule Remedy.Schema.AuditLog.Change do
# use Remedy.Schema, :model

# @primary_key {:id, :id, autogenerate: false}
# schema "audit_logs" do
# field :target_id, :string
# embeds_many :changes, Change
# belongs_to :user, User
# field :action_type, :integer
# field :options, Option
# field :reason, :string
# end
# end
