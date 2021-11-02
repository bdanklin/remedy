defmodule Remedy.Schema.Presence do
  @moduledoc """
  Presence object.

  While presence is updated on a per guild basis. It is always the same between guilds. If your bot shares a number of servers with the same users then it will receive updates from each guild. The only time this has a potential to be different is for Bot users - which are able to set their status on a per shard basis. For this reason the guild_id is not cached or stored on the presence object within Remedy.
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
  def form(params), do: params |> changeset() |> apply_changes()
  @doc false
  def shape(model, params), do: model |> changeset(params) |> apply_changes()
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

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:name, :type, :party_id])
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
