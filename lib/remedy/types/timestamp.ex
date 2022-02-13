defmodule Remedy.Timestamp do
  @moduledoc """
  `Ecto.Type` compatible Discord Timestamp type.

  (The 3rd custom time format required for Discord.)

  This is a standard Unix timestamp, with a millisecond precision.

  ## Casting

  The following are examples of valid inputs for casting. Regardless of the format provided, values will be cast to an `t:integer/0` value for storage.

  #### Snowflake

      927056337051992064


  #### DateTime

      ~U[2021-12-13T15:15:30.455Z]


  #### ISO8601 String

      "2020-01-01T00:00:00.000Z"


  #### Unix

      1577836800

  """

  import Remedy.TimeHelpers
  use Ecto.Type
  use Unsafe.Generator, handler: :unwrap, docs: false

  @typedoc "A Discord Timestamp."
  @type t :: 1_420_034_400_000..4_102_408_800_000
  use Unsafe.Generator, handler: :unwrap, docs: false

  @typedoc "Castable to Discord Timestamp."
  @type c() :: t() | DateTime.t() | integer() | String.t()

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
  def cast(value), do: to_iso8601(value) |> casted()

  defp casted(nil), do: :error
  defp casted(:error), do: :error
  defp casted(datetime), do: {:ok, datetime}

  @doc false
  @impl true
  @unsafe {:dump, [:value]}
  def dump(nil), do: {:ok, nil}
  def dump(value), do: to_unixtime(value) |> casted()

  @doc false
  @impl true
  def load(value), do: {:ok, to_iso8601(value)}

  @doc false
  @impl true
  def equal?(term1, term2), do: to_unixtime(term1) == to_unixtime(term2)

  @doc false
  @impl true
  def embed_as(_value), do: :dump

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise(ArgumentError)
end
