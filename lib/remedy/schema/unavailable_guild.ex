defmodule Remedy.Schema.UnavailableGuild do
  @moduledoc false
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          unavailable: true
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "guilds" do
    field :unavailable, :boolean
  end
end
