defmodule Remedy.Schema.UserGuildBans do
  use Remedy.Schema

  @primary_key false
  schema "user_guild_bans" do
    belongs_to :user, Snowflake
    belongs_to :guild, Snowflake
  end
end
