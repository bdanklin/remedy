defmodule Remedy.Schema.CommandPermission do
  @moduledoc """
  Command Permission Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          type: CommandPermissionType.t(),
          permission: :boolean
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :type, CommandPermissionType
    field :permission, :boolean
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
