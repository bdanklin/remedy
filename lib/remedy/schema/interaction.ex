defmodule Remedy.Schema.Interaction do
  @moduledoc """
  Interaction Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: integer(),
          data: InteractionData.t(),
          token: String.t(),
          version: integer(),
          channel: Channel.t(),
          member: Member.t(),
          user: User.t(),
          message: Message.t(),
          guild: Guild.t(),
          application: App.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "interaction" do
    field :type, :integer
    embeds_one :data, InteractionData
    field :token, :string
    field :version, :integer
    belongs_to :channel, Channel
    embeds_one :member, Member
    belongs_to :user, User
    belongs_to :message, Message
    belongs_to :guild, Guild
    belongs_to :application, App
  end
end
