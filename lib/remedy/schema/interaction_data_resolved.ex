defmodule Remedy.Schema.InteractionDataResolved do
  @moduledoc """
  Interaction Data Resolved Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          users: [User.t()],
          members: [Member.t()],
          roles: [Role.t()],
          channels: [Channel.t()],
          messages: [Message.t()]
        }

  embedded_schema do
    embeds_many :users, User
    embeds_many :members, Members
    embeds_many :roles, Roles
    embeds_many :channels, Channels
    embeds_many :messages, Messages
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
