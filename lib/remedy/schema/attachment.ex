defmodule Remedy.Schema.Attachment do
   @moduledoc """
  Discord Attachment Object
  """
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "attachments" do
    field :filename, :string, required: true
    field :content_type, :string, required: true
    field :size, :integer, required: true
    field :url, :string, required: true
    field :proxy_url, :string, required: true
    field :height, :integer
    field :width, :integer
  end
end
