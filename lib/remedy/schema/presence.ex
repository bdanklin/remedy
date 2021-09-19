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

  def validate(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_inclusion(:status, ["idle", "dnd", "online", "offline"])
  end
end
