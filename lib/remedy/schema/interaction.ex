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

defmodule Remedy.Schema.InteractionData do
  @moduledoc """
  This is the center point between Commands, Interactions and Components.

  Should probably be the center point of any command framework
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          name: String.t(),
          type: integer(),
          custom_id: String.t(),
          component_type: integer(),
          values: [String.t()],
          target_id: Snowflake.t(),
          resolved: InteractionDataResolved.t(),
          options: [InteractionDataOption.t()]
        }

  @primary_key false
  embedded_schema do
    field :id, Snowflake
    field :name, :string
    field :type, :integer
    field :custom_id, :string
    field :component_type, :integer
    field :values, {:array, :string}
    field :target_id, Snowflake
    embeds_one :resolved, InteractionDataResolved
    embeds_many :options, InteractionDataOption
  end
end

defmodule Remedy.Schema.InteractionDataOption do
  @moduledoc """
  Interaction Data Option Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          type: integer(),
          value: String.t(),
          options: [__MODULE__.t()]
        }

  embedded_schema do
    field :name, :string
    field :type, :integer
    field :value, :string
    embeds_many :options, __MODULE__
  end
end

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
