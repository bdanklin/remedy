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
