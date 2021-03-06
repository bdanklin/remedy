defmodule Remedy.Schema.App do
  @moduledoc """
  Application Object

  > Called `App` due to conflicts with Elixirs `Application` module.

  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          name: String.t(),
          icon: String.t(),
          description: String.t(),
          summary: String.t(),
          bot: User.t(),
          bot_public: boolean(),
          bot_require_code_grant: boolean(),
          terms_of_service_url: String.t(),
          privacy_policy_url: String.t(),
          owner: User.t(),
          cover_image: String.t(),
          flags: ApplicationFlags.t()
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :name, :string
    field :icon, :string
    field :description, :string
    field :bot_public, :boolean
    field :bot_require_code_grant, :boolean
    field :terms_of_service_url, :string
    field :privacy_policy_url, :string
    field :cover_image, :string
    field :flags, ApplicationFlags

    embeds_one :bot, User
    field :summary, :string

    embeds_one :owner, User
    field :remedy_system, :boolean, default: false
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embed(:owner)
  end

  @doc false
  def system_changeset(model \\ %__MODULE__{}, params) do
    model
    |> changeset(params)
    |> put_change(:remedy_system, true)
  end
end
