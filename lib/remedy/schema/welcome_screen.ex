defmodule Remedy.Schema.WelcomeScreen do
  use Remedy.Schema

  @moduledoc """
  Guild Welcome Screen
  """

  @type t :: %__MODULE__{
          description: String.t(),
          welcome_channels: [WelcomeScreenChannel.t()]
        }

  @primary_key false
  embedded_schema do
    field :description, :string
    embeds_many :welcome_channels, WelcomeScreenChannel
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:description])
    |> cast_embed(:welcome_channels)
  end
end

defmodule Remedy.Schema.WelcomeScreenChannel do
  use Remedy.Schema

  @moduledoc """
  Guild Welcome Screen Channel
  """

  @type t :: %__MODULE__{
          channel_id: Snowflake.t(),
          description: String.t(),
          emoji_id: Snowflake.t(),
          emoji_name: String.t()
        }
  @primary_key false
  embedded_schema do
    field :channel_id, Snowflake
    field :description, :string
    field :emoji_id, Snowflake
    field :emoji_name, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:channel_id, :description, :emoji_id, :emoji_name])
  end
end
