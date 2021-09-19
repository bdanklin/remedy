defmodule Remedy.Schema.Command do
  @moduledoc """
  Discord Command Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: integer(),
          name: String.t(),
          description: String.t(),
          default_permission: boolean(),
          application: App.t(),
          guild: Guild.t(),
          options: Option.t()
        }

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

  def validate(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 32)
  end
end
