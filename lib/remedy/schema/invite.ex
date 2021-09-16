defmodule Remedy.Schema.Invite do
  @moduledoc """
  Invite Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          target_type: integer(),
          approximate_presence_count: integer(),
          approximate_member_count: integer(),
          expires_at: ISO8601.t(),
          uses: integer(),
          max_uses: integer(),
          max_age: integer(),
          temporary: integer(),
          created_at: integer(),
          target_user: User.t(),
          channel: Channel.t(),
          guild: Guild.t(),
          inviter: User.t()
        }

  @primary_key {:code, :string, autogenerate: false}
  schema "invites" do
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
