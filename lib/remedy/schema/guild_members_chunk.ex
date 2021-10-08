defmodule Remedy.Schema.GuildMembersChunk do
  @moduledoc false
  use Remedy.Schema

  @type t :: %__MODULE__{
          guild_id: Snowflake.t(),
          members: [Member.t()],
          presences: [Presence.t()],
          chunk_index: integer(),
          chunk_count: integer(),
          not_found: [String.t()],
          nonce: String.t()
        }

  embedded_schema do
    field :guild_id, Snowflake
    embeds_many :members, Member
    embeds_many :presences, Presence
    field :chunk_index, :integer
    field :chunk_count, :integer
    field :not_found, {:array, :string}
    field :nonce, :string
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
