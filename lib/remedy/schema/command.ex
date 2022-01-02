defmodule Remedy.Schema.Command do
  @moduledoc """
  Discord Command Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: CommandType.t(),
          name: String.t(),
          description: String.t(),
          default_permission: boolean(),
          application_id: Snowflake.t(),
          guild_id: Snowflake.t(),
          options: CommandOption.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "commands" do
    field :type, CommandType
    field :name, :string
    field :description, :string
    field :default_permission, :boolean, default: true
    field :application_id, Snowflake
    field :guild_id, Snowflake
    embeds_many :options, Option
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
    |> validate_required([:name])
    |> validate_length(:name, max: 32)
  end
end
