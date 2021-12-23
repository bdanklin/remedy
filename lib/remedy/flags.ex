defmodule Remedy.Flag do
  @moduledoc false

  ### Assists with bit flag manipulation.
  ##
  ##  Set a struct with the bit values of a flag.
  ##
  ##  use Remedy.Flag
  ##  defstruct  CROSSPOSTED: 1 <<< 0,
  ##             IS_CROSSPOST: 1 <<< 1,
  ##             SUPPRESS_EMBEDS: 1 <<< 2,
  ##             SOURCE_MESSAGE_DELETED: 1 <<< 3,
  ##             URGENT: 1 <<< 4,
  ##             HAS_THREAD: 1 <<< 5,
  ##             EPHEMERAL: 1 <<< 6,
  ##             LOADING: 1 <<< 7
  ##
  ##  Each of the following functions will be available in the module:
  ##
  ##  to_map(), to_integer(), to_list()
  ##
  ##  You will also be able to use it as an Ecto Type. Which will be accepted in
  ##  either of the 3 forms, but always stored in the database as the integer value.

  defmacro __using__(_opts) do
    quote do
      alias __MODULE__
      use Bitwise, only_operators: true
      use Ecto.Type

      @before_compile Remedy.Flag
      @after_compile Remedy.FlagAfterCompile
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @doc """
      Returns the boolean map representation of the bit flag.
      """

      def to_map(boolean_map) when is_map(boolean_map) do
        boolean_map
      end

      def to_map(flag_value) when is_integer(flag_value) do
        for {flag, value} <- Map.from_struct(%__MODULE__{}), into: %{} do
          {flag, (flag_value &&& value) == value}
        end
      end

      def to_map(set) when is_list(set) do
        set =
          Enum.map(set, &to_string(&1))
          |> Enum.map(&String.to_atom(&1))

        for {flag, value} <- Map.from_struct(%__MODULE__{}), into: %{} do
          {flag, value in set}
        end
      end

      @doc """
      Returns the list representation of the bit flag.

      Accepts either a boolean map,
      """
      def to_list(boolean_map) when is_map(boolean_map) do
        boolean_map
        |> Enum.filter(fn {_k, v} -> v == true end)
        |> Keyword.keys()
      end

      def to_list(flag_value) when is_integer(flag_value) do
        for {flag, value} <- Map.from_struct(%__MODULE__{}), into: %{} do
          {flag, (flag_value &&& value) == value}
        end
        |> Enum.filter(fn {_k, v} -> v == true end)
        |> Keyword.keys()
      end

      def to_list(flag_value) when is_list(flag_value) do
        flag_value
      end

      @doc """
      Returns the integer representation of the bit flag.
      """
      def to_integer(flag_value) when is_integer(flag_value) do
        flag_value
      end

      def to_integer(set) when is_list(set) do
        set =
          Enum.map(set, &to_string(&1))
          |> Enum.map(&String.to_atom(&1))

        %__MODULE__{}
        |> Map.from_struct()
        |> Enum.filter(fn {k, v} -> k in set end)
        |> Enum.reduce(0, fn {k, v}, acc -> acc + v end)
      end

      def to_integer(boolean_map) do
        Enum.reduce(boolean_map, 0, fn {flag, enabled}, flag_value ->
          case enabled do
            true -> flag_value ||| Map.from_struct(%__MODULE__{})[flag]
            false -> flag_value
          end
        end)
      end

      @doc false
      def cast(nil), do: {:ok, nil}
      def cast(value) when is_integer(value), do: {:ok, value |> to_integer()}
      def cast(value) when is_map(value), do: {:ok, value |> to_integer()}
      def cast(value) when is_list(value), do: {:ok, value}
      def cast(_value), do: :error

      @doc false

      def dump(value) when is_integer(value), do: {:ok, value}
      def dump(value) when is_map(value), do: {:ok, value |> to_integer()}
      def dump(value) when is_list(value), do: {:ok, value |> to_integer()}
      def dump(_value), do: :error

      @doc false
      def load(value) when is_integer(value), do: {:ok, value |> to_list()}

      @doc false
      def type, do: :integer
    end
  end
end

defmodule Remedy.FlagAfterCompile do
  @moduledoc false
  def __after_compile__(_env, _bytecode) do
    quote do
      @impl true
      @doc false
      def equal?(term1, term2), do: to_integer(term1) == to_integer(term2)

      @doc false
      def embed_as, do: :dump
    end
  end
end
