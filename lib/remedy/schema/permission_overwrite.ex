defmodule Remedy.Schema.PermissionOverwrite do
  @moduledoc false
  # type	int	either 0 (role) or 1 (member) <- use to build changeset
  use Remedy.Schema
  @primary_key false

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          role: Role.t(),
          user: User.t(),
          type: integer(),
          allow: String.t(),
          deny: String.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "permission_overwrite" do
    embeds_one :role, Role
    embeds_one :user, User
    field :type, :integer
    field :allow, :string
    field :deny, :string
  end

  @doc false
  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  @doc false
  def validate(any), do: any
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
