defmodule Remedy.Schema.ThreadMetadata do
  use Remedy.Schema

  @type t :: %__MODULE__{
          archived: boolean(),
          auto_archive_duration: integer(),
          archive_timestamp: ISO8601.t(),
          locked: boolean(),
          invitable: boolean()
        }

  embedded_schema do
    field :archived, :boolean
    field :auto_archive_duration, :integer
    field :archive_timestamp, ISO8601
    field :locked, :boolean
    field :invitable, :boolean
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(changeset) do
    changeset
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
