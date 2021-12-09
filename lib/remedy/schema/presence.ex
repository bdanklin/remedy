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
    # belongs_to :guild, Guild
    field :activities, {:array, :map}
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
    |> cast(params, [:code, :user_id, :status, :activities])
    |> cast_embed(:client_status)
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
