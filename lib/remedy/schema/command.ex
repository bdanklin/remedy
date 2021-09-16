defmodule Remedy.Schema.Command do
   @moduledoc """
  Discord Command Object
  """
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :type, :integer, default: 1
    field :name, :string
    field :description, :string
    field :default_permission, :boolean, default: true

    belongs_to :application, App
    belongs_to :guild, Guild

    embeds_many :options, Option
  end

  def validate(model) do
    model
    |> validate_required([:name])
    |> validate_length(:name, max: 32)
  end
end
