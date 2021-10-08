defmodule Remedy.Schema.UserFlags do
  use Remedy.Schema
  use BattleStandard

  @flag_bits [
    {:DISCORD_EMPLOYEE, 1 <<< 0},
    {:PARTNERED_SERVER_OWNER, 1 <<< 1},
    {:HYPESQUAD_EVENTS, 1 <<< 2},
    {:BUG_HUNTER_LEVEL_1, 1 <<< 3},
    {:HYPESQUAD_BRAVERY, 1 <<< 6},
    {:HYPESQUAD_BRILLIANCE, 1 <<< 7},
    {:HYPESQUAD_BALANCE, 1 <<< 8},
    {:EARLY_SUPPORTER, 1 <<< 9},
    {:TEAM_USER, 1 <<< 10},
    {:SYSTEM, 1 <<< 12},
    {:BUG_HUNTER_LEVEL_2, 1 <<< 14},
    {:VERIFIED_BOT, 1 <<< 16},
    {:VERIFIED_DEVELOPER, 1 <<< 17},
    {:DISCORD_CERTIFIED_MODERATOR, 1 <<< 18}
  ]

  @moduledoc """
  User Flags

  """

  @type discord_employee :: boolean()
  @type partnered_server_owner :: boolean()
  @type hypesquad_events :: boolean()
  @type bug_hunter_level_1 :: boolean()
  @type hypesquad_bravery :: boolean()
  @type hypesquad_brilliance :: boolean()
  @type hypesquad_balance :: boolean()
  @type early_supporter :: boolean()
  @type team_user :: boolean()
  @type system :: boolean()
  @type bug_hunter_level_2 :: boolean()
  @type verified_bot :: boolean()
  @type verified_developer :: boolean()
  @type discord_certified_moderator :: boolean()

  @type t :: %__MODULE__{
          DISCORD_EMPLOYEE: discord_employee,
          PARTNERED_SERVER_OWNER: partnered_server_owner,
          HYPESQUAD_EVENTS: hypesquad_events,
          BUG_HUNTER_LEVEL_1: bug_hunter_level_1,
          HYPESQUAD_BRAVERY: hypesquad_bravery,
          HYPESQUAD_BRILLIANCE: hypesquad_brilliance,
          HYPESQUAD_BALANCE: hypesquad_balance,
          EARLY_SUPPORTER: early_supporter,
          TEAM_USER: team_user,
          SYSTEM: system,
          BUG_HUNTER_LEVEL_2: bug_hunter_level_2,
          VERIFIED_BOT: verified_bot,
          VERIFIED_DEVELOPER: verified_developer,
          DISCORD_CERTIFIED_MODERATOR: discord_certified_moderator
        }

  embedded_schema do
    field :DISCORD_EMPLOYEE, :boolean, default: false
    field :PARTNERED_SERVER_OWNER, :boolean, default: false
    field :HYPESQUAD_EVENTS, :boolean, default: false
    field :BUG_HUNTER_LEVEL_1, :boolean, default: false
    field :HYPESQUAD_BRAVERY, :boolean, default: false
    field :HYPESQUAD_BRILLIANCE, :boolean, default: false
    field :HYPESQUAD_BALANCE, :boolean, default: false
    field :EARLY_SUPPORTER, :boolean, default: false
    field :TEAM_USER, :boolean, default: false
    field :SYSTEM, :boolean, default: false
    field :BUG_HUNTER_LEVEL_2, :boolean, default: false
    field :VERIFIED_BOT, :boolean, default: false
    field :VERIFIED_DEVELOPER, :boolean, default: false
    field :DISCORD_CERTIFIED_MODERATOR, :boolean, default: false
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(changeset) do
    changeset
  end

  @doc false
  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end
end
