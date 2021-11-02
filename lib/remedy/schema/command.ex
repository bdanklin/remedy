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
          options: CommandOption.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "commands" do
    field :type, :integer, default: 1
    field :name, :string
    field :description, :string
    field :default_permission, :boolean, default: true
    belongs_to :application, App
    belongs_to :guild, Guild
    embeds_many :options, Option
  end

  @doc false
  def form(params), do: params |> changeset() |> apply_changes()
  @doc false
  def shape(model, params), do: model |> changeset(params) |> apply_changes()
  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end

  @doc false
  def validate(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 32)
  end
end

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
    embeds_many :options, CommandOptions
    field :channel_types, {:array, :integer}
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end

defmodule Remedy.Schema.CommandOptionChoice do
  @moduledoc """
  Command Option Choice
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          value: any()
        }

  embedded_schema do
    field :name, :string
    field :value, :any, virtual: true
  end
end
