defmodule Remedy.Factory do
  @moduledoc false
  alias Faker
  use Remedy.Schema, :schema_alias

  @spec snowflake() :: Snowflake.t()
  def snowflake, do: Faker.random_between(0x400000, 0xFFFFFFFFFFFFFFFF)

  @spec timestamp() :: Timestamp.t()
  def timestamp, do: Faker.random_between(1_420_034_400_000, 4_102_408_800_000)
end
