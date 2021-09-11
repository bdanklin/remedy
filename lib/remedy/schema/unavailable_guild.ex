defmodule Remedy.Schema.UnavailableGuild do
  @moduledoc false
  use Remedy.Schema
  @primary_key {:id, Snowflake, autogenerate: false}

  schema "guilds" do
    field :unavailable, :boolean
  end
end
