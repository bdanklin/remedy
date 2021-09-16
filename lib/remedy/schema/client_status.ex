defmodule Remedy.Schema.ClientStatus do
  @moduledoc false
  use Remedy.Schema
  @primary_key false

  schema "client_statuses" do
    field :desktop, :string
    field :mobile, :string
    field :web, :string
  end
end
