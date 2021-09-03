defmodule Remedy.Cache.GuildCacheTest do
  use ExUnit.Case

  alias Remedy.Cache.GuildCache
  alias Remedy.Struct.Guild

  setup_all do
    :ets.new(GuildCache.tabname(), [:set, :public, :named_table])
    assert true = GuildCache.create(%Guild{id: 0})
    :ok
  end

  doctest GuildCache
end
