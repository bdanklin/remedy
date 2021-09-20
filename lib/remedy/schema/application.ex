defmodule Remedy.Schema.App do
  @moduledoc """
  Discord Application Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          name: String.t(),
          icon: String.t(),
          description: String.t(),
          rpc_origins: [String.t()],
          bot_public: boolean(),
          bot_require_code_grant: boolean(),
          terms_of_service_url: String.t(),
          privacy_policy_url: String.t(),
          cover_image: String.t(),
          flags: integer(),
          summary: String.t(),
          verify_key: String.t(),
          owner: User.t(),
          team: Team.t(),
          guild_id: Guild.t(),
          primary_sku_id: Snowflake.t(),
          slug: String.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "applications" do
    field :name, :string
    field :icon, :string
    field :description, :string
    field :rpc_origins, {:array, :string}
    field :bot_public, :boolean
    field :bot_require_code_grant, :boolean
    field :terms_of_service_url, :string
    field :privacy_policy_url, :string
    field :cover_image, :string
    field :flags, :integer
    field :summary, :string
    field :verify_key, :string

    belongs_to :owner, User
    belongs_to :team, Team
    belongs_to :guild, Guild
    field :primary_sku_id, Snowflake
    field :slug, :string
  end

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
  end

  def validate(changeset), do: changeset

  def changeset(params), do: changeset(%__MODULE__{}, params)
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = model, params) do
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
