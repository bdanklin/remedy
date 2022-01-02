defmodule Remedy.Schema.ClientStatus do
  @moduledoc """
  Discord Presence Client Status Object
  """
  use Remedy.Schema
  @primary_key false

  @type t :: %__MODULE__{
          desktop: String.t(),
          mobile: String.t(),
          web: String.t()
        }

  @primary_key false
  embedded_schema do
    field :desktop, :string
    field :mobile, :string
    field :web, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    params = for {k, v} <- params, into: %{}, do: {k, to_string(v)}

    model
    |> cast(params, [:desktop, :mobile, :web])
  end
end
