defmodule Remedy.Schema.VoiceServerUpdate do
  use Remedy.Schema

  embedded_schema do
    field :token, :string
    field :guild_id, Snowflake
    field :endpoint, :string
  end

  @doc false
  def form(attrs), do: changeset(attrs) |> apply_changes()

  @doc false
  def changeset(module \\ %__MODULE__{}, attrs) do
    cast(module, attrs, [:token, :guild_id, :endpoint])
  end
end
