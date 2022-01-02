defmodule Remedy.Schema.Interaction do
  @moduledoc """
  Interaction Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: InteractionType.t(),
          data: InteractionData.t(),
          token: String.t(),
          version: integer(),
          channel: Channel.t(),
          member: Member.t(),
          user: User.t(),
          message: Message.t(),
          guild: Guild.t(),
          application: App.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "interaction" do
    field :type, InteractionType
    field :token, :string
    field :version, :integer

    embeds_one :user, User
    embeds_one :message, Message
    embeds_one :data, InteractionData
    embeds_one :member, Member

    belongs_to :application, App
    belongs_to :channel, Channel
    belongs_to :guild, Guild
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    cast = __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
    params = put_inserted_at(params)

    model
    |> cast(params, cast)
    |> cast_embed(:user)
    |> cast_embed(:message)
    |> cast_embed(:data)
    |> cast_embed(:member)
  end

  defp put_inserted_at(params) do
    params |> Map.put_new(:inserted_at, DateTime.now!("Etc/UTC"))
  end
end
