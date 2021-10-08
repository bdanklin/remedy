defmodule Remedy.Schema.Command do
  @moduledoc """
  Discord Command Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: integer(),
          name: String.t(),
          description: String.t(),
          default_permission: boolean(),
          application: App.t(),
          guild: Guild.t(),
          options: CommandOption.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :type, :integer, default: 1
    field :name, :string
    field :description, :string
    field :default_permission, :boolean, default: true
    belongs_to :application, App
    belongs_to :guild, Guild
    embeds_many :options, Option
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
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

  @doc false
  def validate(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 32)
  end
end
