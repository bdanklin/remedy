defmodule Remedy.Schema.Invite do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key {:code, :string, autogenerate: false}

  schema "voice_regions" do
    field :target_type, :integer
    field :approximate_presence_count, :integer
    field :approximate_member_count, :integer
    field :expires_at, ISO8601
    field :uses, :integer
    field :max_uses, :integer
    field :max_age, :integer
    field :temporary, :integer
    field :created_at, :integer
    embeds_one :target_user, User
    belongs_to :channel, Channel
    belongs_to :guild, Guild
    belongs_to :inviter, User
  end
end
