defmodule Remedy.Schema.Emoji do
  @moduledoc """
  Discord Emoji Object
  """
  use Remedy.Schema
  alias Remedy.CDN

  @type t :: %__MODULE__{
          name: String.t(),
          roles: [Role.t()],
          require_colons: boolean(),
          managed: boolean(),
          animated: boolean(),
          available: boolean(),
          user: User.t(),
          guild: Guild.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "emojis" do
    field :name, :string
    field :roles, {:array, Snowflake}
    field :require_colons, :boolean
    field :managed, :boolean
    field :animated, :boolean
    field :available, :boolean
    belongs_to :user, User
    belongs_to :guild, Guild
  end

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
  end

  def validate(changeset), do: changeset

  def changeset(params), do: changeset(%__MODULE__{}, params)
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = model, params) do
    cast(model, params, castable())
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end

  @doc """

  > Mention is more of a ping. potentially rename

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
