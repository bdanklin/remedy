defmodule Remedy.Factory do
  alias Faker
  alias Remedy.Snowflake

  @spec snowflake :: Snowflake.t()
  def snowflake do
    Snowflake.factory()
  end
end
