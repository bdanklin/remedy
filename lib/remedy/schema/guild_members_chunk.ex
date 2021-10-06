defmodule Remedy.Schema.GuildMemberChunk do
  @moduledoc false
  use Remedy.Schema

  embedded_schema do
    field :guild_id, :integer
    embeds_many :members, Member
    embeds_many :presences, Presence
    field :chunk_index, :integer
    field :chunk_count, :integer
    field :not_found, {:array, :string}
    field :nonce, :string
  end

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def validate(changeset) do
    changeset
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
