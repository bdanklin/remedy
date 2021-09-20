defmodule Remedy.Schema.Presence do
  @moduledoc """
  Presence object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          user: User.t(),
          guild_id: Snowflake.t(),
          status: String.t(),
          activities: [Activity.t()],
          client_status: ClientStatus.t()
        }

  @primary_key {:code, :string, autogenerate: false}
  schema "presences" do
    belongs_to :user, User
    field :guild_id, Snowflake
    field :status, :string
    embeds_many :activities, Activity
    embeds_one :client_status, ClientStatus
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

  def validate(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_inclusion(:status, ["idle", "dnd", "online", "offline"])
  end
end
