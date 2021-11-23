defmodule Remedy.Schema.Ban do
  @moduledoc """
  Discord Ban Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          user_id: Snowflake.t(),
          guild_id: Snowflake.t(),
          reason: String.t(),
          invalid_since: DateTime.t()
        }

  # Primary key :guild_id ++ :user_id
  @primary_key {:id, :id, autogenerate: false}
  schema "bans" do
    field :user_id, Snowflake
    field :guild_id, Snowflake
    field :reason, :string
    field :invalid_since, :utc_datetime, default: nil
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    params = params |> put_pkey()

    model
    |> cast(params, [:user_id, :guild_id, :reason])
    |> validate_required([:user_id, :guild_id])
  end

  @doc false
  def make_invalid_changeset(model, _params \\ %{}) do
    model
    |> cast(%{invalid_since: DateTime.now!("Etc/UTC")}, [:invalid_since])
  end

  def put_pkey(%{user_id: user_id, guild_id: guild_id} = params) do
    id = "#{guild_id}#{user_id}" |> Integer.parse() |> elem(0)

    Map.put_new(params, :id, id)
  end
end
