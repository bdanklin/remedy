defmodule Remedy.Cache do
  import Remedy.ModelHelpers
  import Ecto.Query, warn: false
  alias Fish.Repo
  alias Remedy.Schema.Channel

  @moduledoc """
  Functions for interracting with the cache.
  """

  def create_channel(channel) do
    channel
    |> Channel.changeset()
    |> Repo.insert!()
  end

  def update_channel(%{id: id} = channel) do
    Channel
    |> Repo.get!(id)
    |> Channel.changeset(channel)
    |> Repo.update!()
  end

  def delete_channel(%{id: id} = _channel) do
    Channel
    |> Repo.get!(id)
    |> Repo.delete!()
  end
end
