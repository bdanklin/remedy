defmodule Remedy.Schema.Attachment do
  @moduledoc """
  Discord Attachment Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          filename: String.t(),
          content_type: String.t(),
          size: integer(),
          url: String.t(),
          proxy_url: String.t(),
          height: integer(),
          width: integer(),
          ephemeral: boolean()
        }

  @doc """
  Attachment Schema
  """
  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :filename, :string
    field :content_type, :string
    field :size, :integer
    field :url, :string
    field :proxy_url, :string
    field :height, :integer
    field :width, :integer
    field :ephemeral, :boolean
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:filename, :content_type, :size, :url, :proxy_url, :height, :width, :ephemeral])
    |> validate_required([:id, :filename, :content_type, :size, :url])
  end
end
