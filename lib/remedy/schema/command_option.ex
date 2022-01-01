defmodule Remedy.Schema.CommandOption do
  @moduledoc """
  Command Option Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: integer(),
          name: String.t(),
          description: String.t(),
          required: boolean(),
          choices: [CommandOptionChoice.t()],
          options: [__MODULE__.t()],
          channel_types: [integer()]
        }

  embedded_schema do
    field :type, :integer
    field :name, :string
    field :description, :string
    field :required, :boolean
    embeds_many :choices, CommandOptionChoice
    embeds_many :options, __MODULE__
    field :channel_types, {:array, :integer}
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
