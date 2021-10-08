defmodule Remedy.Schema.PresenceUpdate do
  @moduledoc false
  use Remedy.Schema
  @primary_key {:id, :id, autogenerate: false}

  # either "idle", "dnd", "online", or "offline"

  @type t :: %__MODULE__{
          user: User.t(),
          guild: Guild.t(),
          status: String.t(),
          client_status: ClientStatus.t(),
          activities: [Activity.t()]
        }

  embedded_schema do
    belongs_to :user, User
    belongs_to :guild, Guild
    field :status, :string
    embeds_one :client_status, ClientStatus
    embeds_many :activities, Activity
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
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
