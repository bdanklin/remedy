defmodule Remedy.Struct.Guild.Role do
  @moduledoc ~S"""
  Struct representing a Discord role.

  ## Mentioning Roles in Messages

  A `Remedy.Struct.Guild.Role` can be mentioned in message content using the `String.Chars`
  protocol or `mention/1`.

  ```Elixir
  role = %Remedy.Struct.Guild.Role{id: 431886897539973131}
  Remedy.Api.create_message!(184046599834435585, "#{role}")
  %Remedy.Struct.Message{}

  role = %Remedy.Struct.Guild.Role{id: 431884023535632398}
  Remedy.Api.create_message!(280085880452939778, "#{Remedy.Struct.Guild.Role.mention(role)}")
  %Remedy.Struct.Message{}
  ```
  """

  alias Remedy.{Snowflake, Util}

  defstruct [
    :id,
    :name,
    :color,
    :hoist,
    :position,
    :permissions,
    :managed,
    :mentionable
  ]

  defimpl String.Chars do
    def to_string(role), do: @for.mention(role)
  end

  @typedoc "The id of the role"
  @type id :: Snowflake.t()

  @typedoc "The name of the role"
  @type name :: String.t()

  @typedoc "The hexadecimal color code"
  @type color :: integer

  @typedoc "Whether the role is pinned in the user listing"
  @type hoist :: boolean

  @typedoc "The position of the role"
  @type position :: integer

  @typedoc "The permission bit set"
  @type permissions :: integer

  @typedoc "Whether the role is managed by an integration"
  @type managed :: boolean

  @typedoc "Whether the role is mentionable"
  @type mentionable :: boolean

  @type t :: %__MODULE__{
          id: id,
          name: name,
          color: color,
          hoist: hoist,
          position: position,
          permissions: permissions,
          managed: managed,
          mentionable: mentionable
        }

  @doc ~S"""
  Formats an `Remedy.Struct.Role` into a mention.

  ## Examples

  ```Elixir
  iex> role = %Remedy.Struct.Guild.Role{id: 431886639627763722}
  ...> Remedy.Struct.Guild.Role.mention(role)
  "<@&431886639627763722>"
  ```
  """
  @spec mention(t) :: String.t()
  def mention(%__MODULE__{id: id}), do: "<@&#{id}>"

  @doc false
  def p_encode do
    %__MODULE__{}
  end

  @doc false
  def to_struct(map) do
    new =
      map
      |> Map.new(fn {k, v} -> {Util.maybe_to_atom(k), v} end)
      |> Map.update(:id, nil, &Util.cast(&1, Snowflake))

    struct(__MODULE__, new)
  end
end
