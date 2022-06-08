defmodule Remedy.Schema.Integration do
  @moduledoc """
  Integration Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          name: String.t(),
          type: IntegrationType.t(),
          enabled: boolean(),
          syncing: boolean(),
          role_id: Snowflake.t(),
          enable_emoticons: boolean(),
          expire_behavior: IntegrationExpireType.t(),
          expire_grace_period: integer(),
          user: User.t(),
          account: IntegrationAccount.t(),
          synced_at: ISO8601.t(),
          subscriber_count: integer(),
          revoked: boolean(),
          application: App.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :name, :string
    field :type, IntegrationType
    field :enabled, :boolean
    field :syncing, :boolean
    field :role_id, Snowflake
    field :enable_emoticons, :boolean
    field :expire_behavior, IntegrationExpireType
    field :expire_grace_period, :integer
    field :synced_at, ISO8601
    field :subscriber_count, :integer
    field :revoked, :boolean

    embeds_one :account, IntegrationAccount
    embeds_one :user, User
    embeds_one :application, App
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
