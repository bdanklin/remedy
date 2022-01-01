defmodule Remedy.Schema.VoiceServerUpdate do
  use Remedy.Schema

  embedded_schema do
    field :token, :string
    field :guild_id, Snowflake
    field :endpoint, :string
  end

  @doc false
  def changeset(module \\ %__MODULE__{}, params) do
    cast(module, params, [:token, :guild_id, :endpoint])
  end
end
