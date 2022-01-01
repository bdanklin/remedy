defmodule Remedy.Type do
  @moduledoc false
  ##  Type behaviour is concerned with type / radio types
  ##
  ##  Various fields within discord display data as a type represented by an integer
  ##
  ##  This module will implement
  ##  - Ecto.Type to use in an Ecto Schema
  ##  - helper functions.
  ##
  ##  Do not specify @moduledoc or @type
  ##
  ##  The example below is generated from
  ##
  ##  https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-types
  ##
  ##  defmodule Remedy.Schema.MessageTypes do
  ##    use Remedy.Type
  ##    defstruct  CHAT_INPUT: 1,
  ##               USER: 2,
  ##               MESSAGE: 3
  ##  end
  ##
  ##  It can be represented in multiple ways:
  ##
  ##  As an integer
  ##  1
  ##
  ##  As an atom
  ##  :CHAT_INPUT
  ##
  ##  As a string
  ##  "CHAT_INPUT"
  ##
  ##  Each of the following functions will be available in the module:
  ##
  ##  - to_integer/1
  ##  - to_string/1
  ##
  ##  The generated types can accept any of these formats when casting.
  ##  The DB will always store integer values.

  @doc false
  @callback to_binary(any) :: any

  @doc false
  @callback to_integer(any) :: any

  defmacro __using__(_env) do
    quote do
      @behaviour Remedy.Type
      alias __MODULE__
      use Ecto.Type

      @before_compile Remedy.TypeBeforeCompile
    end
  end
end

defmodule Remedy.TypeBeforeCompile do
  @moduledoc false
  defmacro __before_compile__(_env) do
    quote do
      use Remedy.TypeType,
        type_spec: Remedy.TypeType.type_spec(%__MODULE__{}),
        type_doc: Remedy.TypeType.type_doc(%__MODULE__{}),
        module_doc: Remedy.TypeType.module_doc(%__MODULE__{})

      defp keys, do: %__MODULE__{} |> Map.from_struct() |> Enum.map(fn {k, _v} -> to_string(k) end)
      defp key_vals, do: %__MODULE__{} |> Map.from_struct() |> Enum.map(fn {k, v} -> {to_string(k), v} end)
      defp vals, do: %__MODULE__{} |> Map.from_struct() |> Enum.map(fn {_k, v} -> v end)

      defp key_for(val) when is_integer(val),
        do: key_vals() |> Enum.filter(fn {k, v} -> v == val end) |> List.first() |> elem(0)

      @doc false
      @impl true
      def to_integer(type)
      def to_integer(atom) when is_atom(atom), do: %__MODULE__{}[atom]
      def to_integer(integer) when is_integer(integer), do: if(integer in vals(), do: integer, else: :error)

      def to_integer(string) when is_binary(string) do
        # case of "5" etc. Because fuck knows when it comes to discord.
        case Integer.parse(string) do
          {integer, ""} ->
            to_integer(integer)

          :error ->
            case string in keys() do
              true -> key_vals()[string]
              false -> :error
            end
        end
      end

      @doc false
      @impl true
      def to_binary(integer) when is_integer(integer), do: if(integer in vals(), do: key_for(integer), else: :error)
      def to_binary(string) when is_atom(string), do: if(Atom.to_string(string) in keys(), do: string, else: :error)
      def to_binary(string) when is_binary(string), do: if(string in keys(), do: string, else: :error)

      @doc false
      def cast(nil), do: {:ok, nil}
      def cast(value) when is_integer(value), do: {:ok, value |> to_integer()}
      def cast(value) when is_binary(value), do: {:ok, value |> to_integer()}
      def cast(value) when is_atom(value), do: {:ok, value |> to_integer()}
      def cast(_value), do: :error

      @doc false
      def dump(value) when is_integer(value), do: {:ok, value |> to_integer()}
      def dump(value) when is_binary(value), do: {:ok, value |> to_integer()}
      def dump(value) when is_atom(value), do: {:ok, value |> to_integer()}
      def dump(_value), do: :error

      @doc false
      def load(value) when is_integer(value), do: {:ok, value |> to_binary()}

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

defmodule Remedy.TypeType do
  @moduledoc false
  defmacro __using__(type_spec: type_spec, type_doc: type_doc, module_doc: module_doc) do
    quote bind_quoted: [type_spec: type_spec, type_doc: type_doc, module_doc: module_doc] do
      @moduledoc module_doc
      @typedoc type_doc
      @type unquote({:t, [], Elixir}) :: unquote(type_spec)
    end
  end

  def module_doc(_struct),
    do: """
    `Ecto.Type` compatible Type type ( type? ¿ǝdʎʇ ).
    """

  def type_spec(struct) when is_struct(struct), do: struct |> vals() |> Enum.sort_by(& &1) |> type_spec()
  def type_spec([item]), do: item
  def type_spec([head | tail]), do: {:|, [], [head, type_spec(tail)]}

  def type_doc(struct),
    do: ~s(#{name(struct)} Values

  | Value | Type  |
  | ----: | ----  |
#{rows(struct)}

## Representations

The following representations are all valid when casting to a schema.

#### Integer Type
```elixir
#{integer_type(struct)}
```

#### String Type
```elixir
#{string_type(struct)}
```

#### Atom Type
```elixir
#{atom_type(struct)}
```
)

  defp name(%name{} = struct) when is_struct(struct) do
    name |> Module.split() |> List.last() |> Recase.to_title()
  end

  defp rows(struct) do
    struct
    |> Map.from_struct()
    |> Enum.map(fn {k, v} -> {v, row(k, v)} end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.reduce("", fn {_k, v}, acc -> acc <> v end)
  end

  defp row(k, v) do
    " | `#{v}` | `:#{to_string(k)}` | \n "
  end

  defp integer_type(struct) do
    struct
    |> vals()
    |> Enum.random()
    |> inspect(pretty: true)
  end

  defp string_type(struct) do
    struct
    |> keys()
    |> Enum.random()
    |> inspect(pretty: true)
  end

  defp atom_type(struct) do
    struct
    |> keys()
    |> Enum.random()
    |> String.to_existing_atom()
    |> inspect(pretty: true)
  end

  ## Keys, Vals, KeysVals Helpers

  defp keys(struct) do
    struct
    |> Map.from_struct()
    |> Enum.map(fn {k, _v} -> to_string(k) end)
  end

  defp vals(struct) do
    struct
    |> Map.from_struct()
    |> Enum.map(fn {_k, v} -> v end)
  end
end
