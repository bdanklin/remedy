defmodule Remedy.Schema.Activity do
  @moduledoc """
  Activity Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          type: ActivityType.t(),
          url: URL.t() | nil,
          created_at: Timestamp.t(),
          timestamps: ActivityTimestamps.t() | nil,
          application_id: Snowflake.t() | nil,
          details: String.t() | nil,
          state: String.t() | nil,
          emoji: Emoji.t() | nil,
          party: ActivityParty.t() | nil,
          assets: ActivityAssets.t() | nil,
          secrets: ActivitySecrets.t() | nil,
          instance: boolean() | nil,
          flags: ActivityFlags.t() | nil,
          buttons: [ActivityButton.t()] | nil
        }

  @primary_key false
  embedded_schema do
    field :name, :string
    field :type, ActivityType
    field :url, URL
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
    keys = [:name, :type, :url, :created_at, :application_id, :details, :state, :instance, :flags]

    model
    |> cast(params, keys)
    |> cast_embed(:timestamps)
    |> cast_embed(:emoji)
    |> cast_embed(:party)
    |> cast_embed(:assets)
    |> cast_embed(:secrets)
    |> cast_embed(:buttons)
  end
end
