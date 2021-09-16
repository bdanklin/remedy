defmodule Remedy.Cache do
  import Remedy.ModelHelpers
  import Ecto.Query, warn: false
  alias Remedy.Repo

  @moduledoc """
  Functions for interracting with the cache.
  """
  alias Remedy.Schema.Channel

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

  def delete_channel(id) do
    Channel
    |> Repo.get!(id)
    |> Repo.delete!()
  end

  alias Remedy.Schema.Guild

  def create_guild(guild) do
    guild
    |> Guild.changeset()
    |> Repo.insert!()
  end

  def update_guild(%{id: id} = guild) do
    Guild
    |> Repo.get!(id)
    |> Guild.changeset(guild)
    |> Repo.update!()
  end

  def delete_guild(%{id: id} = _guild) do
    Guild
    |> Repo.get!(id)
    |> Repo.delete!()
  end

  alias Remedy.Schema.User

  def create_user(user) do
    user
    |> User.changeset()
    |> Repo.insert!()
  end

  def update_user(%{id: id} = user) do
    User
    |> Repo.get!(id)
    |> User.changeset(user)
    |> Repo.update!()
  end

  def delete_user(%{id: id} = _user) do
    User
    |> Repo.get!(id)
    |> Repo.delete!()
  end

  alias Remedy.Schema.Member

  def create_member(member) do
    member
    |> Member.changeset()
    |> Repo.insert!()
  end

  def update_member(%{id: id} = member) do
    Member
    |> Repo.get!(id)
    |> Member.changeset(member)
    |> Repo.update!()
  end

  def delete_member(%{id: id} = _member) do
    Member
    |> Repo.get!(id)
    |> Repo.delete!()
  end
end
