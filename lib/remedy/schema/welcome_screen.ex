defmodule Remedy.Schema.WelcomeScreen do
  use Remedy.Schema

  @moduledoc """
  Guild Welcome Screen
  """

  @type description :: String.t()
  @type welcome_channels :: [WelcomeScreenChannel.t()]

  @type t :: %__MODULE__{
          description: description,
          welcome_channels: welcome_channels
        }

  @primary_key false
  embedded_schema do
    field :description, :string
    embeds_many :welcome_channels, WelcomeScreenChannel
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

defmodule Remedy.Schema.WelcomeScreenChannel do
  use Remedy.Schema

  @moduledoc """
  Guild Welcome Screen
  """

  @type channel_id :: Snowflake.t()
  @type description :: String.t()
  @type emoji_id :: Snowflake.t()
  @type emoji_name :: String.t()

  @type t :: %__MODULE__{
          channel_id: channel_id,
          description: description,
          emoji_id: emoji_id,
          emoji_name: emoji_name
        }
  @primary_key false
  embedded_schema do
    field :channel_id, Snowflake
    field :description, :string
    field :emoji_id, Snowflake
    field :emoji_name, :string
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
