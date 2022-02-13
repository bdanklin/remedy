defmodule Remedy.Schema.Attachment do
  @moduledoc """
  Discord Attachment Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          filename: String.t(),
          description: String.t() | nil,
          content_type: String.t() | nil,
          size: integer(),
          url: URL.t(),
          proxy_url: String.t(),
          height: integer() | nil,
          width: integer() | nil,
          ephemeral: boolean() | nil
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :filename, :string
    field :description, :string
    field :content_type, :string
    field :size, :integer
    field :url, URL
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
    field :ephemeral, :boolean
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:filename, :description, :content_type, :size, :url, :proxy_url, :height, :width, :ephemeral])
  end
end
