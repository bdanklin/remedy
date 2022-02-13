defmodule Remedy.Dispatch.Payloads.ChannelUpdate do
  @moduledoc false
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :type, ChannelType
    field :position, :integer
    field :name, :string
    field :topic, :string
    field :nsfw, :boolean
    field :bitrate, :integer
    field :user_limit, :integer
    field :rate_limit_per_user, :integer
    field :last_pin_timestamp, :string
    field :rtc_region, :string
    field :video_quality_mode, :integer
    field :default_auto_archive_duration, :integer
    field :permissions, :string
    field :parent_id, Snowflake
    field :guild_id, Snowflake
    embeds_many :permission_overwrites, PermissionOverwrite
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
    |> validate_required([:id, :type])
  end
end
