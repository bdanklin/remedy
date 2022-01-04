defmodule Remedy.Snowflake do
  @moduledoc """
  `Ecto.Type` compatible Discord Snowflake type.

  Discord utilizes Twitter's snowflake format for uniquely identifiable descriptors (IDs). These IDs are guaranteed to be unique across all of Discord, except in some unique scenarios in which child objects share their parent's ID.

  Snowflakes consist of a timestamp as well as metadata. Converting to another timestamp method will produce a valid and accurate timestamp. However, converting a value from a snowflake is a destructive operation and cannot be reversed.

      iex> snowflake = 927056337051992064
      ...> butchered_snowflake = snowflake |> Remedy.ISO8601.to_iso8601() |> Remedy.Snowflake.to_snowflake()
      ...> butchered_snowflake == snowflake
      false

  While the utilities exist to execute such functionality, care should be taken.

  For example:
  - Converting an ISO8601 string to a snowflake for the purpose of pagination is reasonably safe to do.
  - Using a message's snowflake ID in a filtering operation is also safe.
  - Converting a DateTime struct to a snowflake to attempt to get a message's ID is not.

  ## Pagination

  Discord typically uses snowflake IDs in many of the API routes for pagination. The standardized pagination paradigm utilized is one in which you can specify IDs before and after in combination with limit to retrieve a desired page of results. You will want to refer to the specific endpoint documentation for details.

  ## Casting

  The following are examples of valid inputs for casting. Regardless of the format provided, values will be cast to an `t:integer/0` value for storage.

  #### Decimal Integer

      927056337051992064


  #### ISO8601 String

      "2019-01-01T00:00:00Z"

  """
  import Remedy.TimeHelpers
  use Ecto.Type
  use Unsafe.Generator, handler: :unwrap, docs: false

  @doc false

  def factory, do: Faker.random_between(0x400000, 0xFFFFFFFFFFFFFFFF)

  @typedoc """
  A Discord Snowflake Type.
  """
  @type t() :: 0x400000..0xFFFFFFFFFFFFFFFF

  @typedoc """
  Castable to Discord Snowflake.
  """
  @type c() :: t() | ISO8601.t() | DateTime.t() | integer()

  @doc false
  @impl true
  @spec type :: :integer
  def type, do: :integer

  @spec cast(any) :: :error | {:ok, nil | t()}
  @doc false
  @impl true
  @unsafe {:cast, [:value]}
  def cast(value)
  def cast(nil), do: {:ok, nil}
  def cast(value), do: to_snowflake(value) |> casted()

  defp casted(:error), do: :error
  defp casted(snowflake), do: {:ok, snowflake}

  @doc false
  @impl true
  @unsafe {:dump, [:snowflake]}
  def dump(nil), do: {:ok, nil}
  def dump(value) when is_snowflake(value), do: {:ok, to_snowflake(value)}
  def dump(_value), do: :error

  @doc false
  @impl true
  def load(value) when is_snowflake(value), do: {:ok, value}

  @doc false
  @impl true
  def equal?(term1, term2), do: to_snowflake(term1) == to_snowflake(term2)

  @doc false
  @impl true
  def embed_as(_value), do: :dump

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise(ArgumentError)
end
