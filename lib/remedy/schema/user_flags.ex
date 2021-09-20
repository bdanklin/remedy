defmodule Remedy.Schema.UserFlags do
  @moduledoc false
  use Remedy.Schema

  @type t :: %__MODULE__{
          DISCORD_EMPLOYEE: boolean(),
          PARTNERED_SERVER_OWNER: boolean(),
          HYPESQUAD_EVENTS: boolean(),
          BUG_HUNTER_LEVEL_1: boolean(),
          HYPESQUAD_BRAVERY: boolean(),
          HYPESQUAD_BRILLIANCE: boolean(),
          HYPESQUAD_BALANCE: boolean(),
          EARLY_SUPPORTER: boolean(),
          TEAM_USER: boolean(),
          SYSTEM: boolean(),
          BUG_HUNTER_LEVEL_2: boolean(),
          VERIFIED_BOT: boolean(),
          VERIFIED_DEVELOPER: boolean(),
          DISCORD_CERTIFIED_MODERATOR: boolean()
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
end
