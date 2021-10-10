defmodule Remedy.Gateway.DispatchTest do
  use ExUnit.Case
  alias Remedy.Gateway.Dispatch
  doctest Dispatch

  describe "test dispatcher" do
    test "mod from dispatch" do
      assert Dispatch.mod_from_dispatch(:THREAD_CREATE) == Remedy.Gateway.Dispatch.ThreadCreate
    end
  end
end
