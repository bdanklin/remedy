defmodule Remedy.Schema.Ready do
  @moduledoc false
  use Remedy.Schema

  @type t :: %__MODULE__{
          v: integer(),
          session_id: String.t(),
          shard: [integer()],
          user: User.t(),
          application: App.t(),
          guilds: [UnavailableGuild.t()]
        }

  embedded_schema do
    field :v, :integer
    field :session_id, :string
    field :shard, {:array, :integer}
    embeds_one :user, User
    embeds_one :application, App
    embeds_many :guilds, UnavailableGuild
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

defmodule Remedy.Schema.UnavailableGuild do
  @moduledoc false
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          unavailable: true
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :unavailable, :boolean
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:id, :unavailable])
  end
end
