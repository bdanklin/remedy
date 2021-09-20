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

  embedded_schema do
    belongs_to :user, User
    belongs_to :guild, Guild
    field :reason, :string
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
    cast(model, params, castable())
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
