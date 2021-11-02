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
          width: integer()
        }

  @primary_key false
  embedded_schema do
    field :filename, :string, required: true
    field :content_type, :string, required: true
    field :size, :integer, required: true
    field :url, :string, required: true
    field :proxy_url, :string, required: true
    field :height, :integer
    field :width, :integer
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast(model, params, fields -- embeds)
  end
end
