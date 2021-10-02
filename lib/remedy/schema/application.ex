defmodule Remedy.Schema.App do
  @moduledoc """
  Discord Application Object
  """
  use Remedy.Schema

  @type name :: String.t()
  @type icon :: String.t()
  @type description :: String.t()
  @type rpc_origins :: [String.t()]
  @type bot_public :: boolean()
  @type bot_require_code_grant :: boolean()
  @type terms_of_service_url :: String.t()
  @type privacy_policy_url :: String.t()
  @type cover_image :: String.t()
  @type flags :: integer()
  @type summary :: String.t()
  @type verify_key :: String.t()
  @type owner :: User.t()
  @type team :: Team.t()
  @type guild_id :: Guild.t()
  @type primary_sku_id :: Snowflake.t()
  @type slug :: String.t()
  @type hook :: boolean()

  @type t :: %__MODULE__{
          name: name,
          icon: icon,
          description: description,
          rpc_origins: rpc_origins,
          bot_public: bot_public,
          bot_require_code_grant: bot_require_code_grant,
          terms_of_service_url: terms_of_service_url,
          privacy_policy_url: privacy_policy_url,
          owner: owner,
          summary: summary,
          verify_key: verify_key,
          team: team,
          guild_id: guild_id,
          primary_sku_id: primary_sku_id,
          slug: slug,
          cover_image: cover_image,
          flags: flags,
          hook: hook
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "applications" do
    field :name, :string
    field :icon, :string
    field :description, :string, optional: true
    field :rpc_origins, {:array, :string}
    field :bot_public, :boolean
    field :bot_require_code_grant, :boolean
    field :terms_of_service_url, :string
    field :privacy_policy_url, :string
    field :cover_image, :string
    field :flags, :integer
    field :summary, :string
    field :verify_key, :string
    field :hook, :boolean

    embeds_one :owner, User
    belongs_to :team, Team
    belongs_to :guild, Guild
    field :primary_sku_id, Snowflake
    field :slug, :string
  end

  def new(params) do
    params
    |> changeset()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> apply_changes()
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
