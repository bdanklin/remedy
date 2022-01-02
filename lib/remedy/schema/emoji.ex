defmodule Remedy.Schema.Emoji do
  @moduledoc """
  Discord Emoji Object
  """
  use Remedy.Schema
  alias Remedy.CDN

  @typedoc """
  Emoji Type.
  """
  @type t :: %__MODULE__{
          id: Snowflake.t() | nil,
          name: String.t(),
          require_colons: boolean() | nil,
          managed: boolean() | nil,
          animated: boolean() | nil,
          available: boolean() | nil,
          user: User.t() | nil,
          guild: Guild.t() | nil
        }

  @typedoc """
  Castable to Emoji.
  """
  @type c :: params() | t()

  @typedoc """
  Emoji Params Type
  """
  @type params :: %{
          required(:name) => String.t(),
          optional(:id) => Snowflake.t(),
          optional(:require_colons) => boolean(),
          optional(:managed) => boolean(),
          optional(:animated) => boolean(),
          optional(:available) => boolean(),
          optional(:user) => User.t(),
          optional(:guild) => Guild.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "emojis" do
    field :name, :string
    field :require_colons, :boolean
    field :managed, :boolean
    field :animated, :boolean, default: false
    field :available, :boolean
    belongs_to :user, User
    belongs_to :guild, Guild
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end

  @doc """

  Formats an `Remedy.Struct.Emoji` into a mention.

  ## Examples

      iex> emoji = %Remedy.Struct.Emoji{name: "≡ƒæì"}
      ...> Remedy.Struct.Emoji.mention(emoji)
      "≡ƒæì"

      iex> emoji = %Remedy.Struct.Emoji{id: 436885297037312001, name: "tealixir"}
      ...> Remedy.Struct.Emoji.mention(emoji)
      "<:tealixir:436885297037312001>"

      iex> emoji = %Remedy.Struct.Emoji{id: 437016804309860372, name: "blobseizure", animated: true}
      ...> Remedy.Struct.Emoji.mention(emoji)
      "<a:blobseizure:437016804309860372>"


  """

  @spec mention(t()) :: String.t()
  def mention(emoji)
  def mention(%__MODULE__{id: nil, name: name}), do: name
  def mention(%__MODULE__{animated: true, id: id, name: name}), do: "<a:#{name}:#{id}>"
  def mention(%__MODULE__{id: id, name: name}), do: "<:#{name}:#{id}>"

  @doc """
  Formats an emoji struct into its `t:Remedy.Struct.Emoji.api_name/0`.

  ## Examples

      iex> emoji = %Remedy.Struct.Emoji{name: "Γ¡É"}
      ...> Remedy.Struct.Emoji.api_name(emoji)
      "Γ¡É"

      iex> emoji = %Remedy.Struct.Emoji{id: 437093487582642177, name: "foxbot"}
      ...> Remedy.Struct.Emoji.api_name(emoji)
      "foxbot:437093487582642177"

  """

  @spec api_name(t) :: String.t()
  def api_name(emoji)
  def api_name(%__MODULE__{id: nil, name: name}), do: name
  def api_name(%__MODULE__{id: id, name: name}), do: "#{name}:#{id}"

  @doc """
  Returns the url of a custom emoji's image. If the emoji is not a custom one,
  returns `nil`.

  ## Examples

      iex> emoji = %Remedy.Struct.Emoji{id: 450225070569291776}
      ...> Remedy.Struct.Emoji.image_url(emoji)
      "https://cdn.discordapp.com/emojis/450225070569291776.png"

      iex> emoji = %Remedy.Struct.Emoji{id: 406140226998894614, animated: true}
      ...> Remedy.Struct.Emoji.image_url(emoji)
      "https://cdn.discordapp.com/emojis/406140226998894614.gif"

      iex> emoji = %Remedy.Struct.Emoji{id: nil, name: "Γ¡É"}
      ...> Remedy.Struct.Emoji.image_url(emoji)
      nil

  """
  @spec image_url(t) :: String.t() | nil
  def image_url(emoji)
  def image_url(%__MODULE__{id: nil}), do: nil
  def image_url(%__MODULE__{id: id}), do: CDN.custom_emoji(id)
end
