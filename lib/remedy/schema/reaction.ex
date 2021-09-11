defmodule Remedy.Schema.Reaction do
  @moduledoc false
  use Remedy.Schema
  @primary_key false

  embedded_schema do
    field :count, :integer
    field :me, :boolean
    embeds_one :emoji, Emoji
  end
end
