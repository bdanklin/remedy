defmodule Remedy.Dispatch.Cache.Invite do
  @moduledoc false
  use Remedy.Schema

  @primary_key {:code, :string, autogenerate: false}
  schema "invites" do
    field :target_type, InviteTargetType
    field :approximate_presence_count, :integer
    field :approximate_member_count, :integer
    field :expires_at, ISO8601
    field :uses, :integer
    field :max_uses, :integer
    field :max_age, :integer
    field :temporary, :integer
    field :created_at, :integer
    embeds_one :target_user, User
    embeds_one :channel, Channel
    embeds_one :guild, Guild
    embeds_one :inviter, User
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [
      :target_type,
      :approximate_presence_count,
      :approximate_member_count,
      :expires_at,
      :uses,
      :max_uses,
      :max_age,
      :temporary,
      :created_at
    ])
  end
end
