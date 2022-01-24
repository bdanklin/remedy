defmodule Remedy.Rest.Lifeguard.StateTest do
  import Remedy.Rest.Lifeguard.State
  use ExUnit.Case

  describe "refresh ttl" do
    test "compute a new TTL" do
      assert refresh_ttl(%Remedy.Rest.Lifeguard.State{
               min: 2,
               max: 10,
               workers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
             }) == %Remedy.Rest.Lifeguard.State{}
    end
  end
end
