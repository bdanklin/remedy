defmodule Remedy.Gateway.Events.Ready do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :v, :integer
    field :session_id, :string
    field :shard, {:array, :integer}
    embeds_one :application, App
    embeds_one :user, User
    embeds_many :guilds, Guild
  end

  alias Remedy.Struct.Event.PartialApplication
  alias Remedy.Struct.Guild.UnavailableGuild
  alias Remedy.Struct.User

  @typedoc """
  Gateway version.
  See https://discord.com/developers/docs/topics/gateway#gateways-gateway-versions
  """
  @type v :: non_neg_integer()

  @typedoc "Information about the bot user"
  @type user :: User.t()

  @typedoc "The guilds that the bot user is in"
  @type guilds :: [UnavailableGuild.t()]

  @typedoc """
  Used for resuming connections.

  If you are wondering whether you need to use this, you probably don't.
  Remedy handles reconnections for you.
  """
  @type session_id :: String.t()

  @typedoc """
  A pair of two integers ``{shard_id, num_shards}``.

  For more information, see
  https://discord.com/developers/docs/topics/gateway#sharding.
  """
  @type shard :: {integer(), non_neg_integer()} | nil

  @typedoc "Partial application object with `id` and `flags`"
  @type application :: PartialApplication.t()

  @typedoc "Event sent after initial handshake with the gateway"
  @type t :: %__MODULE__{
          v: v,
          user: user,
          guilds: guilds,
          session_id: session_id,
          shard: shard,
          application: application
        }

  @doc false
end
