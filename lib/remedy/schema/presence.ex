defmodule Remedy.Schema.Presence do
  @moduledoc """
  Presence object.

  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          code: String.t(),
          status: String.t(),
          user: User.t(),
          activities: [Activity.t()],
          client_status: ClientStatus.t()
        }

  @primary_key false
  embedded_schema do
    field :code, :string
    field :status, :string
    belongs_to :user, User
    field :guild_id, Snowflake
    field :activities, {:array, :map}
    embeds_one :client_status, ClientStatus, on_replace: :delete
  end

  @doc false

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:code, :user_id, :status, :activities])
    |> cast_embed(:client_status)
  end
end
