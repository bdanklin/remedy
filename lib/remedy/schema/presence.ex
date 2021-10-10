defmodule Remedy.Schema.Presence do
  @moduledoc """
  Presence object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          status: String.t(),
          activities: [Activity.t()],
          client_status: ClientStatus.t(),
          code: String.t()
        }

  @primary_key false
  embedded_schema do
    field :code, :string
    field :guild_id, Snowflake
    field :status, :string
    embeds_many :activities, Activity, on_replace: :delete
    embeds_one :client_status, ClientStatus, on_replace: :delete
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
