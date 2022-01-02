defmodule Remedy.Schema.PermissionOverwriteType do
  use Remedy.Type

  defstruct ROLE: 0,
            MEMBER: 1
end
