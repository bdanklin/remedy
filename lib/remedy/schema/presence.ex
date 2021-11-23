defmodule Remedy.Schema.Presence do
  @moduledoc """
  Presence object.

  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          status: String.t(),
          activities: [Activity.t()],
          client_status: ClientStatus.t(),
          code: String.t()
        }

  @primary_key false
  embedded_schema do
    field :code, :string
    field :status, :string
    belongs_to :user, User
    belongs_to :guild, Guild
    embeds_many :activities, Activity, on_replace: :delete
    embeds_one :client_status, ClientStatus, on_replace: :delete
  end

  @doc false

  def changeset(model \\ %__MODULE__{}, params) do
    params =
      params
      |> Map.put(:status, params[:status] |> to_string())
      |> Map.put_new(:user_id, params[:user][:id])
      |> Map.delete(:user)

    model
    |> cast(params, [:code, :user_id, :guild_id, :status])
    |> cast_embed(:activities)
    |> cast_embed(:client_status)
  end
end

defmodule Remedy.Schema.Activity do
  @moduledoc """
  Discord Presence Activity Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          type: integer(),
          party_id: String.t()
        }

  @primary_key false
  embedded_schema do
    field :id, :string
    field :name, :string
    field :type, :integer
    field :party_id, :string
    field :created_at, ISO8601
    field :details, :string
    field :assets, {:map, :string}
    field :party, {:map, :string}
    field :session_id, :string
    field :state, :string
    field :sync_id, :string
    field :timestamps, {:map, ISO8601}
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [
      :id,
      :name,
      :type,
      :party_id,
      :created_at,
      :details,
      :assets,
      :party,
      :session_id,
      :state,
      :sync_id,
      :timestamps
    ])
  end
end

defmodule Remedy.Schema.ClientStatus do
  @moduledoc """
  Discord Presence Client Status Object
  """
  use Remedy.Schema
  @primary_key false

  @type t :: %__MODULE__{
          desktop: String.t(),
          mobile: String.t(),
          web: String.t()
        }

  @primary_key false
  embedded_schema do
    field :desktop, :string
    field :mobile, :string
    field :web, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    params = for {k, v} <- params, into: %{}, do: {k, to_string(v)}

    model
    |> cast(params, [:desktop, :mobile, :web])
  end
end
