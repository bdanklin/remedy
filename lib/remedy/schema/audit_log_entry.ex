defmodule Remedy.Schema.AuditLogEntry do
  @moduledoc """
  Discord Audit Log Entry Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          target_id: String.t(),
          action_type: integer(),
          reason: String.t(),
          user: User.t(),
          options: [AuditLogOption.t()],
          changes: [map()]
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :target_id, :string
    field :action_type, :integer
    field :reason, :string
    field :changes, {:array, :map}
    belongs_to :user, User
    embeds_many :options, AuditLogOption
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
