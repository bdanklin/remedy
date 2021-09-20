defmodule Remedy.Schema.Interaction do
  @moduledoc """
  Interaction Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: integer(),
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
    field :type, :integer
    embeds_one :data, InteractionData
    field :token, :string
    field :version, :integer
    belongs_to :channel, Channel
    embeds_one :member, Member
    belongs_to :user, User
    belongs_to :message, Message
    belongs_to :guild, Guild
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
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
