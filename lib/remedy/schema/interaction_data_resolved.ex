defmodule Remedy.Schema.InteractionDataResolved do
  @moduledoc """
  Interaction Data Resolved Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          users: [User.t()],
          members: [Member.t()],
          roles: [Role.t()],
          channels: [Channel.t()],
          messages: [Message.t()]
        }

  embedded_schema do
    embeds_many :users, User
    embeds_many :members, Members
    embeds_many :roles, Roles
    embeds_many :channels, Channels
    embeds_many :messages, Messages
  end
end
