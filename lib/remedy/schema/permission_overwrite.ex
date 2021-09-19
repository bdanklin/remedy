defmodule Remedy.Schema.PermissionOverwrite do
  @moduledoc false
  # type	int	either 0 (role) or 1 (member) <- use to build changeset
  use Remedy.Schema
  @primary_key false

  embedded_schema do
    field :id, Snowflake, virtual: true
    embeds_one :role, Role
    embeds_one :user, User
    field :type, :integer
    field :allow, :string
    field :deny, :string
  end
end
