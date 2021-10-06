defmodule Remedy.Schema.Ready do
  @moduledoc false
  use Remedy.Schema

  @type v :: integer()
  @type session_id :: String.t()
  @type shard :: [integer()]
  @type user :: User.t()
  @type application :: App.t()
  @type guilds :: [UnavailableGuild.t()]

  @type t :: %__MODULE__{
          v: v,
          session_id: session_id,
          shard: shard,
          user: user,
          application: application,
          guilds: guilds
        }

  embedded_schema do
    field :v, :integer
    field :session_id, :string
    field :shard, {:array, :integer}
    embeds_one :user, User
    embeds_one :application, App
    embeds_many :guilds, UnavailableGuild
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(any), do: any
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
