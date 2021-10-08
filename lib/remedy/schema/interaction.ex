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

  @primary_key {:id, :id, autogenerate: false}
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

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(changeset) do
    changeset
  end

  @doc false
  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
