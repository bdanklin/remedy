defmodule Remedy.Embed do
  alias Remedy.Schema.Embed

  def new(opts \\ %{}) do
    changeset =
      opts
      |> Enum.into(%{})
      |> Embed.changeset()
  end
end
