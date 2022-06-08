defmodule Remedy.Schema.Interaction do
  @moduledoc """
  Interaction Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          application_id: Snowflake.t(),
          type: InteractionType.t(),
          data: InteractionData.t(),
          guild_id: Snowflake.t(),
          channel_id: Snowflake.t(),
          member: Member.t(),
          user: User.t(),
          token: String.t(),
          version: integer(),
          message: Message.t(),
          locale: String.t(),
          guild_locale: String.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :application_id, Snowflake
    field :type, InteractionType
    field :guild_id, Snowflake
    field :channel_id, Snowflake
    field :token, :string
    field :version, :integer
    field :locale, :string
    field :guild_locale, :string
    embeds_one :data, InteractionData
    embeds_one :member, Member
    embeds_one :user, User
    embeds_one :message, Message
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    cast = __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)

    model
    |> cast(params, cast)
    |> cast_embed(:user)
    |> cast_embed(:message)
    |> cast_embed(:data)
    |> cast_embed(:member)
  end
end
