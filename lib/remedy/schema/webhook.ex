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

  def validate(changeset) do
    changeset
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
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

  def validate(changeset) do
    changeset
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
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

  def validate(changeset) do
    changeset
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
