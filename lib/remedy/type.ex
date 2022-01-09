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
        module_doc: Remedy.TypeType.module_doc(%__MODULE__{}),
        type_spec: Remedy.TypeType.type_spec(%__MODULE__{}),
        type_doc: Remedy.TypeType.type_doc(%__MODULE__{}),
        cast_doc: Remedy.TypeType.cast_doc(%__MODULE__{}),
        cast_spec: Remedy.TypeType.cast_spec(%__MODULE__{}),
        flag_doc: Remedy.TypeType.flag_doc(%__MODULE__{}),
        flag_spec: Remedy.TypeType.flag_spec(%__MODULE__{}),
        load_doc: Remedy.TypeType.load_doc(%__MODULE__{}),
        load_spec: Remedy.TypeType.load_spec(%__MODULE__{})

      use Unsafe.Generator,
        handler: :unwrap,
        docs: false

      defp keys_vals, do: %__MODULE__{} |> Map.from_struct()
      defp keys, do: keys_vals() |> Map.keys()
      defp vals, do: keys_vals() |> Map.values()

      defp key_for(val) when is_integer(val) do
        %__MODULE__{}
        |> Map.from_struct()
        |> Enum.filter(fn {k, v} -> v == val end)
        |> List.first()
        |> elem(0)
      end

      @doc false
      @impl true
      def to_integer(type)

      def to_integer(atom) when is_atom(atom) do
        Map.get(%__MODULE__{} |> Map.from_struct(), atom)
      end

      def to_integer(integer) when is_integer(integer),
        do: if(integer in vals(), do: integer, else: :error)

      def to_integer(string) when is_binary(string) do
        # case of "5" etc. Because fuck knows when it comes to discord.
        case Integer.parse(string) do
          {integer, ""} ->
            to_integer(integer)

          :error ->
            key = String.to_existing_atom(string)

            case keys_vals()[string] do
              nil -> :error
              key -> key
            end
        end
      end

      @doc false
      @impl true
      def to_binary(integer) when is_integer(integer),
        do: if(integer in vals(), do: key_for(integer), else: :error)

      def to_binary(string) when is_atom(string),
        do: if(Atom.to_string(string) in keys(), do: string, else: :error)

      def to_binary(string) when is_binary(string),
        do: if(string in keys(), do: string, else: :error)

      @doc false
      def to_atom_key(type), do: to_binary(type) |> String.to_existing_atom()

      @doc false
      @unsafe {:cast, [:value]}
      def cast(nil), do: {:ok, nil}
      def cast(value) when is_integer(value), do: {:ok, value |> to_integer()}
      def cast(value) when is_binary(value), do: {:ok, value |> to_integer()}
      def cast(value) when is_atom(value), do: {:ok, value |> to_integer()}
      def cast(_value), do: :error

      @doc false
      @unsafe {:dump, [:value]}
      def dump(value), do: {:ok, value |> to_integer()}
      def dump(_value), do: :error

      @doc false
      @unsafe {:load, [:value]}
      def load(value) when is_integer(value), do: {:ok, key_for(value)}

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

  def module_doc(struct),
    do: ~s(`Ecto.Type` compatible Type type type? ¿ǝdʎʇ.


 | Value | Type  |
 | ----: | ----  |
 #{rows(struct)}

## Casting

The following are examples of valid inputs for casting. Regardless of the format provided, values will be cast to an `t:integer/0` value for storage.

#### Integer Type

    #{integer_type(struct)}


#### String Type

    #{string_type(struct)}


#### Atom Type

    #{atom_type(struct)}

)

  def type_doc(struct) do
    "#{name(struct)} Type"
  end

  def type_spec(struct) do
    upper_bound = Map.from_struct(struct) |> Map.values() |> Enum.max()

    {:.., [context: Elixir, import: Kernel], [0, upper_bound]}
  end

  def cast_doc(struct) do
    ~s(Castable to #{name(struct)} Type

See [Casting](#module-casting\) for more information.)
  end

  def cast_spec(_struct) do
    ([{:t, [], Elixir}] ++
       [{:f, [if_undefined: :apply], Elixir}] ++
       [{{:., [], [{:__aliases__, [alias: false], [:String]}, :t]}, [], []}])
    |> pipe_spec()
  end

  def flag_doc(struct) do
    "#{name(struct)} Values"
  end

  def flag_spec(struct) do
    struct |> Map.from_struct() |> Map.keys() |> pipe_spec()
  end

  def load_doc(struct) do
    ~s(Loaded #{name(struct)})
  end

  def load_spec(_struct) do
    {:f, [if_undefined: :apply], Elixir}
  end

  def name(%name{} = struct) when is_struct(struct) do
    name |> Module.split() |> List.last() |> Recase.to_title()
  end

  defp pipe_spec([item]), do: item
  defp pipe_spec([head | tail]), do: {:|, [], [head, pipe_spec(tail)]}

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
    |> Map.from_struct()
    |> Map.values()
    |> Enum.random()
    |> inspect(pretty: true)
  end

  defp string_type(struct) do
    struct
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.random()
    |> Atom.to_string()
    |> inspect(pretty: true)
  end

  defp atom_type(struct) do
    struct
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.random()
    |> inspect(pretty: true)
  end

  ## Keys, Vals, KeysVals Helpers
end
