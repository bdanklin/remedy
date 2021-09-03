defmodule Remedy.Schema.VoiceRegion do
  use Remedy.Schema, :model
  @primary_key {:id, :string, autogenerate: false}

  schema "voice_regions" do
    field :name, :string
    field :vip, :boolean
    field :optimal, :boolean
    field :deprecated, :boolean
    field :custom, :boolean
  end
end
