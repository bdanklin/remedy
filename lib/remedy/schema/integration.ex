defmodule Remedy.Schema.Integration do
  @moduledoc """
  Integration Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          type: String.t(),
          enabled: boolean(),
          app: App.t(),
          guild_id: Snowflake.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :name, :string
    field :type, :string
    field :enabled, :boolean
    belongs_to :app, App
    field :guild_id, Snowflake
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
