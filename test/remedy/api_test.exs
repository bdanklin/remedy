defmodule Remedy.APITest do
  use ExUnit.Case, async: true
  import Remedy.API

  alias Remedy.Schema.{
    AuditLog,
    Channel
  }

  @skip_doctests [
    get_current_bot_application_information: 0,
    get_audit_log: 2
  ]

  # doctest Remedy.API, except: @skip_doctests

  @test_category 872_417_560_094_732_329
  @test_guild 872_417_560_094_732_328
  @test_text_channel 895_068_866_395_385_916
  @test_news_channel 895_069_182_616_547_358
  @test_stage_channel 895_069_308_785_393_704
  @test_voice_channel 895_068_896_309_161_984
  @application_id 883_307_747_305_725_972

  test "get current bot application information" do
    assert get_current_bot_application_information!().id == @application_id
  end

  test "get_current_authorization_information" do
    assert get_current_authorization_information() == {:error, {401, 50001, "Missing Access"}}
  end

  test "get channel" do
    {:ok, %Channel{id: id}} = get_channel(@test_text_channel)

    assert id == @test_text_channel
  end

  test "get guild audit log" do
    {:ok, %AuditLog{guild_id: guild_id}} = get_audit_log(@test_guild)

    assert guild_id == @test_guild
  end
end
