defmodule Remedy.Schema.Webhook do
  @moduledoc """
  Webhook
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          avatar: String.t(),
          name: String.t(),
          token: String.t(),
          type: integer(),
          url: String.t(),
          application: App.t(),
          channel: Channel.t(),
          guild: Guild.t(),
          source_channel: Channel.t(),
          source_guild: Guild.t(),
          user: User.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
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

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
