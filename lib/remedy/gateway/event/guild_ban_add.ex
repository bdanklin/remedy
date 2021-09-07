defmodule Remedy.Gateway.Event.GuildBanAdd do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key false

  embedded_schema do
    embeds_one :guild, Guild
    embeds_one :user, User
  end

  @typedoc "ID of the guild"
  @type guild_id :: Guild.id()

  @typedoc "Banned user"
  @type user :: User.t()

  @typedoc "Event sent when a user is banned from a guild"
  @type t :: %__MODULE__{
          guild_id: guild_id,
          user: user
        }
end
