defmodule Remedy.Flag do
  @moduledoc false
  ##  Flag behaviour is concerned with bit flags / checkox types
  ##
  ##  Various fields within discord display data as flags of bits, their sum,
  ##  or a list of the actual permissions. Sometimes arbitrarily depending on
  ##  the setting.
  ##
  ##  This module will implement
  ##  - Ecto.Type to use in an Ecto Schema
  ##  - helper functions.
  ##
  ##  Do not specify @moduledoc or @type
  ##
  ##  The example below is generated from
  ##
  ##  https://discord.com/developers/docs/resources/channel#message-object-message-flags
  ##
  ##  defmodule Remedy.Schema.MessageFlags do
  ##    use Remedy.Flag
  ##    defstruct  CROSSPOSTED: 1 <<< 0,
  ##               IS_CROSSPOST: 1 <<< 1,
  ##               SUPPRESS_EMBEDS: 1 <<< 2,
  ##               SOURCE_MESSAGE_DELETED: 1 <<< 3,
  ##               URGENT: 1 <<< 4,
  ##               HAS_THREAD: 1 <<< 5,
  ##               EPHEMERAL: 1 <<< 6,
  ##               LOADING: 1 <<< 7
  ##  end
  ##
  ##  It can be represented in multiple ways:
  ##
  ##  As a list
  ##  ["CROSSPOSTED", "URGENT", "HAS_THREAD"]
  ##
  ##  As an integer
  ##  49
  ##
  ##  As a map
  ##  %{CROSSPOSTED: true, URGENT: true, HAS_THREAD: true}
  ##
  ##  Each of the following functions will be available in the module:
  ##
  ##  - to_map/1
  ##  - to_integer/1
  ##  - to_list/1
  ##
  ##  The generated types can accept any of these formats when casting.
  ##  The DB will always store integer values.

  @doc false
  @callback to_map(any) :: any

  @doc false
  @callback to_integer(any) :: any

  @doc false
  @callback to_list(any) :: any

  defmacro __using__(_env) do
    quote do
      @behaviour Remedy.Flag
      alias __MODULE__
      use Bitwise, only_operators: true
      use Ecto.Type

      @before_compile Remedy.FlagBeforeCompile
    end
  end
end

defmodule Remedy.FlagBeforeCompile do
  @moduledoc false
  defmacro __before_compile__(_env) do
    quote do
      use Remedy.FlagType,
        type: Remedy.FlagType.flag_spec(%__MODULE__{}),
        doc: Remedy.FlagType.moduledoc(%__MODULE__{})

      @impl true
      def to_map(flags)

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

      @impl true
      def to_list(flags)

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

      @impl true
      def to_integer(flags)

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
        |> Enum.reduce(0, fn {_k, v}, acc -> acc + v end)
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

      @doc false
      @impl true
      def embed_as(_value), do: :dump

      @doc false
      @impl true
      def equal?(term1, term2), do: to_integer(term1) == to_integer(term2)
    end
  end
end

defmodule Remedy.FlagType do
  @moduledoc false
  defmacro __using__(type: type, doc: doc) do
    quote bind_quoted: [doc: doc, type: type] do
      @moduledoc doc
      @type unquote(type)
    end
  end

  def flag_spec(struct) do
    struct
    |> max_flag_value()
    |> type_ast()
  end

  def max_flag_value(struct) do
    struct
    |> Map.from_struct()
    |> Enum.reduce(0, fn {_k, v}, acc -> acc + v end)
  end

  def type_ast(max) do
    {:"::", [], [{:t, [], Elixir}, {:.., [context: Elixir, import: Kernel], [0, max]}]}
  end

  def moduledoc(flag_struct) do
    ~s(#{title(flag_struct)} Type

#{top_row()}
#{rows(flag_struct)}

## Representations

The following representations are all valid when casting to a schema. However the underlying data will always be stored as an integer, and displayed as a list of strings.

#### Decimal Integer
```elixir
#{inspect(max_flag_value(flag_struct))}
```

#### Binary Integer
```elixir
#{inspect(max_flag_value(flag_struct), base: :binary)}
```

#### String List
```elixir
#{inspect(keys_list(flag_struct), pretty: true)}
```

#### Boolean Map
```elixir
#{inspect(boolean_map(flag_struct), pretty: true)}
```
    )
  end

  defp keys_list(struct) do
    struct
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.map(&Atom.to_string/1)
  end

  defp boolean_map(struct) do
    struct
    |> Map.from_struct()
    |> Enum.map(fn {k, _v} -> {k, true} end)
    |> Enum.into(%{})
  end

  defp title(%name{} = struct) when is_struct(struct) do
    name
    |> Module.split()
    |> List.last()
    |> Recase.to_title()
  end

  def top_row do
    " | Bit | Flag  |\n | ----: | ---- | "
  end

  def rows(struct) do
    struct
    |> Map.from_struct()
    |> Enum.map(fn {k, v} -> {v, row(k, v)} end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.reduce("", fn {_k, v}, acc -> acc <> v end)
  end

  defp row(k, v) do
    bv = bitshift(v)

    " | `1 << #{bv}` | `:#{to_string(k)}` | \n "
  end

  defp bitshift(integer) do
    integer
    |> Integer.to_string(2)
    |> String.trim_leading("1")
    |> String.length()
  end
end
