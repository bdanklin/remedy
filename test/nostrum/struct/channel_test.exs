defmodule Remedy.Struct.ChannelTest do
  use ExUnit.Case, async: true

  alias Remedy.Struct.Channel

  doctest Channel

  describe "String.Chars" do
    test "matches `mention/1`" do
      channel = %Remedy.Struct.Channel{id: 381_889_573_426_429_952}

      assert(to_string(channel) === Channel.mention(channel))
    end
  end
end
