defmodule Remedy.Schema.Activity do
  use Remedy.Schema

  embedded_schema do
    field :name, :string
    field :type, ActivityType
    field :url, :string
    field :created_at, Timestamp
    field :application_id, Snowflake
    field :details, :string
    field :state, :string
    field :instance, :boolean
    field :flags, ActivityFlags
    embeds_one :timestamps, ActivityTimestamps
    embeds_one :emoji, Emoji
    embeds_one :party, ActivityParty
    embeds_one :assets, ActivityAssets
    embeds_one :secrets, ActivitySecrets
    embeds_many :buttons, ActivityButton
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    keys = %__MODULE__{} |> Map.from_struct() |> Map.keys()

    model
    |> cast(params, keys)
  end
end
