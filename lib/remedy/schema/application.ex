defmodule Remedy.Schema.App do
  @moduledoc """
  Discord Application Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          name: String.t(),
          icon: String.t(),
          description: String.t(),
          rpc_origins: [String.t()],
          bot_public: boolean(),
          bot_require_code_grant: boolean(),
          terms_of_service_url: String.t(),
          privacy_policy_url: String.t(),
          #    owner: User.t(),
          summary: String.t(),
          verify_key: String.t(),
          #    team: Team.t(),
          #    guild_id: Guild.t(),
          primary_sku_id: Snowflake.t(),
          slug: String.t(),
          cover_image: String.t(),
          flags: integer(),
          hook: boolean()
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

    # embeds_one :owner, User
    # belongs_to :team, Team
    # belongs_to :guild, Guild
    field :primary_sku_id, Snowflake
    field :slug, :string

    field :remedy_system, :boolean, default: false, redact: true
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
  end

  def system_changeset(model \\ %__MODULE__{}, params) do
    model
    |> changeset(params)
    |> put_change(:remedy_system, true)
  end
end
