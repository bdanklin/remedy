defmodule Remedy.Schema.Command do
  @moduledoc false
  use Remedy.Schema, :model

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "commands" do
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
