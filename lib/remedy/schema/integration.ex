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
  schema "integrations" do
    field :name, :string
    field :type, :string
    field :enabled, :boolean
    belongs_to :app, App
    belongs_to :guild, Guild
  end

  @doc false

  def form(params), do: params |> changeset() |> apply_changes()
  @doc false
  def shape(model, params), do: model |> changeset(params) |> apply_changes()

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
