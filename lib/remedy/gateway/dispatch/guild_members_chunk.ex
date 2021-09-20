defmodule Remedy.Gateway.Dispatch.GuildMemberChunk do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Member{}.

  """
  use Remedy.Schema

  embedded_schema do
    field :guild_id, :integer
    embeds_many :members, Member
    embeds_many :presences, Presence
    field :chunk_index, :integer
    field :chunk_count, :integer
    field :not_found, {:array, :string}
    field :nonce, :string
  end

  alias Remedy.Cache

  def handle({event, %{members: members, presences: presences} = payload, socket}) do
    for member <- members do
      Member.new(member) |> Cache.create_member()
      User.new(member.user) |> Cache.create_user()
    end

    for presence <- presences do
      Presence.new(presence) |> Cache.create_presence()
      User.new(presence.user) |> Cache.create_user()
    end

    {event, new(payload), socket}
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
