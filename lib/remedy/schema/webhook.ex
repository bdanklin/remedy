defmodule Remedy.Schema.Webhook do
  @moduledoc """
  Webhook
  """
  use Remedy.Schema

  @type avatar :: String.t()
  @type name :: String.t()
  @type token :: String.t()
  @type type :: integer()
  @type url :: String.t()
  @type application :: App.t()
  @type channel :: Channel.t()
  @type guild :: Guild.t()
  @type source_channel :: Channel.t()
  @type source_guild :: Guild.t()
  @type user :: User.t()

  @type t :: %__MODULE__{
          avatar: avatar,
          name: name,
          token: token,
          type: type,
          url: url,
          application: application,
          channel: channel,
          guild: guild,
          source_channel: source_channel,
          source_guild: source_guild,
          user: user
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "webhooks" do
    field :avatar, :string
    field :name, :string
    field :token, :string
    field :type, :integer
    field :url, :string
    belongs_to :application, App
    belongs_to :channel, Channel
    belongs_to :guild, Guild
    belongs_to :source_channel, Channel
    belongs_to :source_guild, Guild
    belongs_to :user, User
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
end

defmodule Remedy.Schema.IncomingWebhook do
  @moduledoc """
  Incoming Webhook
  """
  use Remedy.Schema

  @type avatar :: String.t()
  @type name :: String.t()
  @type token :: String.t()
  @type type :: integer()
  @type channel :: Channel.t()
  @type guild :: Guild.t()
  @type user :: User.t()

  @type t :: %__MODULE__{
          name: name,
          type: type,
          token: token,
          avatar: avatar,
          channel: channel,
          guild: guild,
          user: user
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "webhooks" do
    field :name, :string
    field :type, :integer
    field :token, :string
    field :avatar, :string
    belongs_to :channel, Channel
    belongs_to :guild, Guild
    belongs_to :user, User
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
end

defmodule Remedy.Schema.ApplicationWebhook do
  @moduledoc """
  Application Webhook
  """
  use Remedy.Schema

  @type avatar :: String.t()
  @type name :: String.t()
  @type type :: integer()
  @type application :: App.t()

  @type t :: %__MODULE__{
          avatar: avatar,
          name: name,
          type: type,
          application: application
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "webhooks" do
    field :type, :integer
    field :name, :string
    field :avatar, :string
    belongs_to :application, App
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
end
