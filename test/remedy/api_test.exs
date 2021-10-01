defmodule Remedy.APITest do
  use ExUnit.Case, async: true

  alias Remedy.Schema.{
    AuditLog,
    Channel,
    Emoji,
    Guild,
    Interaction,
    Member,
    Message,
    Role,
    User,
    Webhook
  }

  doctest Remedy.API
end
