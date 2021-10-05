defmodule Remedy.APITest do
  use ExUnit.Case, async: true
  import Remedy.API

  alias Remedy.Schema.{
    AuditLog,
    Channel,
    Emoji,
    Guild,
    Interaction,
    Member,
    Message,
    Role,
    User,
    Webhook
  }

  @skip_doctests [
    get_current_bot_application_information: 0,
    get_guild_audit_log: 2
  ]

  # doctest Remedy.API, except: @skip_doctests

  @test_category 872_417_560_094_732_329
  @test_guild 872_417_560_094_732_328
  @test_text_channel 872_417_560_094_732_331
  @test_news_channel 895_069_182_616_547_358
  @test_stage_channel 895_069_308_785_393_704
  @test_voice_channel 895_068_896_309_161_984
  @application_id 883_307_747_305_725_972

  test "get current bot application information" do
    assert get_current_bot_application_information!().id == @application_id
  end

  test "get channel" do
    assert get_channel!(@test_text_channel).id == @test_text_channel
  end
end
