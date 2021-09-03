defmodule Remedy.Struct.Event.GuildBanAdd do
  @moduledoc "Sent when a user is banned from a guild"
  @moduledoc since: "0.5.0"

  alias Remedy.Struct.Guild
  alias Remedy.Struct.User
  alias Remedy.Util

  defstruct [:guild_id, :user]

  @typedoc "ID of the guild"
  @type guild_id :: Guild.id()

  @typedoc "Banned user"
  @type user :: User.t()

  @typedoc "Event sent when a user is banned from a guild"
  @type t :: %__MODULE__{
          guild_id: guild_id,
          user: user
        }

  @doc false
  def to_struct(map) do
    %__MODULE__{
      guild_id: map.guild_id,
      user: Util.cast(map.user, {:struct, User})
    }
  end
end
