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
  ##  - Module Docs
  ##  - Type Specs & Docs
  ##  - Examples
  ##
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
        module_doc: Remedy.FlagType.module_doc(%__MODULE__{}),
        type_spec: Remedy.FlagType.type_spec(%__MODULE__{}),
        type_doc: Remedy.FlagType.type_doc(%__MODULE__{}),
        cast_doc: Remedy.FlagType.cast_doc(%__MODULE__{}),
        cast_spec: Remedy.FlagType.cast_spec(%__MODULE__{}),
        flag_doc: Remedy.FlagType.flag_doc(%__MODULE__{}),
        flag_spec: Remedy.FlagType.flag_spec(%__MODULE__{}),
        load_doc: Remedy.FlagType.load_doc(%__MODULE__{}),
        load_spec: Remedy.FlagType.load_spec(%__MODULE__{})

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

      ## Ecto Type Implementations

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
  defmacro __using__(
             module_doc: module_doc,
             type_spec: type_spec,
             type_doc: type_doc,
             cast_doc: cast_doc,
             cast_spec: cast_spec,
             flag_doc: flag_doc,
             flag_spec: flag_spec,
             load_doc: load_doc,
             load_spec: load_spec
           ) do
    quote bind_quoted: [
            module_doc: module_doc,
            type_spec: type_spec,
            type_doc: type_doc,
            cast_doc: cast_doc,
            cast_spec: cast_spec,
            flag_doc: flag_doc,
            flag_spec: flag_spec,
            load_doc: load_doc,
            load_spec: load_spec
          ] do
      @moduledoc module_doc

      @typedoc type_doc
      @type unquote({:t, [], Elixir}) :: unquote(type_spec)

      @typedoc cast_doc
      @type unquote({:c, [], Elixir}) :: unquote(cast_spec)

      @typedoc flag_doc
      @type unquote({:f, [], Elixir}) :: unquote(flag_spec)

      @typedoc load_doc
      @type unquote({:load, [], Elixir}) :: unquote(load_spec)
    end
  end

  use Bitwise

  def module_doc(flag_struct),
    do: ~s(`Ecto.Type` compatible bit flag type.


 | Bit   | Flag  |
 | ----: | ----- |
#{rows(flag_struct)}

## Casting

The following are examples of valid inputs for casting. Regardless of the format provided, values will be cast to an `t:integer/0` value for storage.

#### Decimal Integer
```elixir
#{decimal_integer(flag_struct)}
```

#### Binary Integer
```elixir
#{binary_integer(flag_struct)}
```

#### String List
```elixir
#{string_list(flag_struct)}
```

#### Atom List
```elixir
#{atom_list(flag_struct)}
```

#### Boolean Map
```elixir
#{boolean_map(flag_struct)}
```
)

  def type_doc(struct) do
    "#{name(struct)} Type"
  end

  def type_spec(struct) do
    upper_bound = Map.from_struct(struct) |> Map.values() |> Enum.sum()

    {:.., [context: Elixir, import: Kernel], [0, upper_bound]}
  end

  def cast_doc(struct) do
    "Castable to #{name(struct)} Type"
  end

  def cast_spec(_struct) do
    ([{:t, [], Elixir}] ++
       [[{:f, [if_undefined: :apply], Elixir}]] ++
       [{:map, [], []}] ++
       [[{{:., [], [{:__aliases__, [alias: false], [:String]}, :t]}, [], []}]])
    |> pipe_spec()
  end

  def flag_doc(struct) do
    "#{name(struct)} Flags"
  end

  def flag_spec(struct) do
    struct |> Map.from_struct() |> Map.keys() |> pipe_spec()
  end

  def load_doc(struct) do
    ~s(Loaded #{name(struct)} Flags)
  end

  def load_spec(_struct) do
    [{:f, [if_undefined: :apply], Elixir}]
  end

  def pipe_spec([item]), do: item
  def pipe_spec([head | tail]), do: {:|, [], [head, pipe_spec(tail)]}

  defp decimal_integer(flag_struct) do
    random_set(flag_struct) |> Enum.reduce(0, fn {_k, v}, acc -> acc + v end) |> inspect(pretty: true)
  end

  defp binary_integer(flag_struct) do
    random_set(flag_struct) |> Enum.reduce(0, fn {_k, v}, acc -> acc + v end) |> inspect(base: :binary, pretty: true)
  end

  defp string_list(struct) do
    random_set(struct)
    |> Map.keys()
    |> Enum.map(&Atom.to_string/1)
    |> inspect(pretty: true)
  end

  defp atom_list(struct) do
    random_set(struct) |> Map.keys() |> inspect(pretty: true)
  end

  def boolean_map(struct) do
    random_set(struct) |> Enum.map(fn {k, _v} -> {k, true} end) |> Enum.into(%{}) |> inspect(pretty: true)
  end

  def name(%name{} = struct) when is_struct(struct) do
    name |> Module.split() |> List.last() |> Recase.to_title()
  end

  defp random_set(struct) do
    take_elements = Enum.random(1..ceil((Map.keys(struct) |> Enum.count()) / 2))

    struct
    |> Map.from_struct()
    |> Enum.shuffle()
    |> Enum.take(take_elements)
    |> Enum.into(%{})
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
