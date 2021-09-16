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
    belongs_to :guild_id, Guild
    field :primary_sku_id, Snowflake
    field :slug, :string
  end
end

defmodule Remedy.Schema.Team do
  @moduledoc """
  Discord Team Object
  """
  use Remedy.Schema
  alias Remedy.Schema.TeamMember

  @type t :: %__MODULE__{
          icon: String.t(),
          name: String.t(),
          owner_user_id: Snowflake.t(),
          application: App.t(),
          team_members: [TeamMember.t()]
        }

  @primary_key {:id, :id, autogenerate: false}
  embedded_schema do
    field :icon, :string
    field :name, :string
    field :owner_user_id, Snowflake
    has_one :application, App
    has_many :team_members, TeamMember
  end
end

defmodule Remedy.Schema.TeamMember do
  @moduledoc """
  Discord Team Member Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          membership_state: integer(),
          permissions: [String.t()],
          team: Team.t(),
          user: User.t()
        }

  @primary_key false
  embedded_schema do
    field :membership_state, :integer
    field :permissions, {:array, :string}
    belongs_to :team, Team
    belongs_to :user, User
  end
end
