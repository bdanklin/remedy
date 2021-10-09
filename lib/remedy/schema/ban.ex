defmodule Remedy.Schema.Ban do
  @moduledoc """
  Discord Ban Object
  """
  use Remedy.Schema
  @primary_key false

  @type t :: %__MODULE__{
          user: User.t(),
          guild: Guild.t(),
          reason: String.t()
        }

  schema "bans" do
    belongs_to :user, User
    belongs_to :guild, Guild
    field :reason, :string

    field :invalid_since, :utc_datetime
    timestamps()
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> apply_changes()
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
