defmodule Remedy.Schema.BotGateway do
  use Remedy.Schema

  @primary_key false
  embedded_schema do
    field :url
    field :shards, :integer
    embeds_one :session_start_limit, SessionStartLimit
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [:url, :shards])
    |> cast_embed(:session_start_limit)
  end
end
