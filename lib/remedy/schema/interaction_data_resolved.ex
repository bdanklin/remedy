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
