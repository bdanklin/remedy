defmodule Remedy.Struct.Emoji do
  @moduledoc ~S"""
  Struct representing a Discord emoji.

  ## Mentioning Emojis in Messages

  A `Remedy.Struct.Emoji` can be mentioned in message content using the `String.Chars`
  protocol or `mention/1`.

  ```Elixir
  emoji = %Remedy.Struct.Emoji{id: 437093487582642177, name: "foxbot"}
  Remedy.Api.create_message!(184046599834435585, "#{emoji}")
  %Remedy.Struct.Message{content: "<:foxbot:437093487582642177>"}

  emoji = %Remedy.Struct.Emoji{id: 436885297037312001, name: "tealixir"}
  Remedy.Api.create_message!(280085880452939778, "#{Remedy.Struct.Emoji.mention(emoji)}")
  %Remedy.Struct.Message{content: "<:tealixir:436885297037312001>"}
  ```

  ## Using Emojis in the Api

  A `Remedy.Struct.Emoji` can be used in `Remedy.Api` by using its api name
  or the struct itself.

  ```Elixir
  emoji = %Remedy.Struct.Emoji{id: 436885297037312001, name: "tealixir"}
  Remedy.Api.create_reaction(381889573426429952, 436247584349356032, Remedy.Struct.Emoji.api_name(emoji))
  {:ok}

  emoji = %Remedy.Struct.Emoji{id: 436189601820966923, name: "elixir"}
  Remedy.Api.create_reaction(381889573426429952, 436247584349356032, emoji)
  {:ok}
  ```

  See `t:Remedy.Struct.Emoji.api_name/0` for more information.
  """

  alias Remedy.{Constants, Snowflake, Util}
  alias Remedy.Struct.Guild.Role
  alias Remedy.Struct.User

  defstruct [
    :id,
    :name,
    :user,
    :require_colons,
    :managed,
    :animated,
    :roles
  ]

  defimpl String.Chars do
    def to_string(emoji), do: @for.mention(emoji)
  end

  @typedoc ~S"""
  Emoji string to be used with the Discord API.

  Some API endpoints take an `emoji`. If it is a custom emoji, it must be
  structured as `"id:name"`. If it is an unicode emoji, it can be structured
  as any of the following:

    * `"name"`
    * A base 16 unicode emoji string.

  `api_name/1` is a convenience function that returns a `Remedy.Struct.Emoji`'s
  api name.

  ## Examples

  ```Elixir
  # Custom Emojis
  "remedy:431890438091489"

  # Unicode Emojis
  "≡ƒæì"
  "\xF0\x9F\x98\x81"
  "\u2b50"
  ```
  """
  @type api_name :: String.t()

  @typedoc "Id of the emoji"
  @type id :: Snowflake.t() | nil

  @typedoc "Name of the emoji"
  @type name :: String.t()

  @typedoc "Roles this emoji is whitelisted to"
  @type roles :: [Role.id()] | nil

  @typedoc "User that created this emoji"
  @type user :: User.t() | nil

  @typedoc "Whether this emoji must be wrapped in colons"
  @type require_colons :: boolean | nil

  @typedoc "Whether this emoji is managed"
  @type managed :: boolean | nil

  @typedoc "Whether this emoji is animated"
  @type animated :: boolean | nil

  @type t :: %__MODULE__{
          id: id,
          name: name,
          roles: roles,
          user: user,
          require_colons: require_colons,
          managed: managed,
          animated: animated
        }

  @doc ~S"""
  Formats an `Remedy.Struct.Emoji` into a mention.

  ## Examples

  ```Elixir
  iex> emoji = %Remedy.Struct.Emoji{name: "≡ƒæì"}
  ...> Remedy.Struct.Emoji.mention(emoji)
  "≡ƒæì"

  iex> emoji = %Remedy.Struct.Emoji{id: 436885297037312001, name: "tealixir"}
  ...> Remedy.Struct.Emoji.mention(emoji)
  "<:tealixir:436885297037312001>"

  iex> emoji = %Remedy.Struct.Emoji{id: 437016804309860372, name: "blobseizure", animated: true}
  ...> Remedy.Struct.Emoji.mention(emoji)
  "<a:blobseizure:437016804309860372>"
  ```
  """
  @spec mention(t) :: String.t()
  def mention(emoji)
  def mention(%__MODULE__{id: nil, name: name}), do: name
  def mention(%__MODULE__{animated: true, id: id, name: name}), do: "<a:#{name}:#{id}>"
  def mention(%__MODULE__{id: id, name: name}), do: "<:#{name}:#{id}>"

  @doc ~S"""
  Formats an emoji struct into its `t:Remedy.Struct.Emoji.api_name/0`.

  ## Examples

  ```Elixir
  iex> emoji = %Remedy.Struct.Emoji{name: "Γ¡É"}
  ...> Remedy.Struct.Emoji.api_name(emoji)
  "Γ¡É"

  iex> emoji = %Remedy.Struct.Emoji{id: 437093487582642177, name: "foxbot"}
  ...> Remedy.Struct.Emoji.api_name(emoji)
  "foxbot:437093487582642177"
  ```
  """
  @spec api_name(t) :: api_name
  def api_name(emoji)
  def api_name(%__MODULE__{id: nil, name: name}), do: name
  def api_name(%__MODULE__{id: id, name: name}), do: "#{name}:#{id}"

  @doc """
  Returns the url of a custom emoji's image. If the emoji is not a custom one,
  returns `nil`.

  ## Examples

  ```Elixir
  iex> emoji = %Remedy.Struct.Emoji{id: 450225070569291776}
  iex> Remedy.Struct.Emoji.image_url(emoji)
  "https://cdn.discordapp.com/emojis/450225070569291776.png"

  iex> emoji = %Remedy.Struct.Emoji{id: 406140226998894614, animated: true}
  iex> Remedy.Struct.Emoji.image_url(emoji)
  "https://cdn.discordapp.com/emojis/406140226998894614.gif"

  iex> emoji = %Remedy.Struct.Emoji{id: nil, name: "Γ¡É"}
  iex> Remedy.Struct.Emoji.image_url(emoji)
  nil
  ```
  """
  @spec image_url(t) :: String.t() | nil
  def image_url(emoji)
  def image_url(%__MODULE__{id: nil}), do: nil

  def image_url(%__MODULE__{animated: true, id: id}),
    do: URI.encode(Constants.cdn_url() <> Constants.cdn_emoji(id, "gif"))

  def image_url(%__MODULE__{id: id}),
    do: URI.encode(Constants.cdn_url() <> Constants.cdn_emoji(id, "png"))

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
      |> Map.update(:roles, nil, &Util.cast(&1, {:list, Snowflake}))
      |> Map.update(:user, nil, &Util.cast(&1, {:struct, User}))

    struct(__MODULE__, new)
  end
end
