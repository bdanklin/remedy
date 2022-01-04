defmodule Remedy.TimeHelpersTest do
  use ExUnit.Case, async: true
  doctest Remedy.TimeHelpers

  describe "to_datetime/1" do
    snowflake = snowflake()

    test "returns nil for nil" do
      assert nil == Remedy.TimeHelpers.to_datetime(nil)
    end

    test "converts a snowflake to datetime" do
      assert ~U[2021-12-13T15:15:30.455Z] == Remedy.TimeHelpers.to_datetime(919_970_797_920_067_654)
    end

    test "converts a datetime string to date time" do
      assert ~U[2021-12-13T15:15:30.455Z] == Remedy.TimeHelpers.to_datetime("2021-12-13T15:15:30.455Z")
    end
  end
end
