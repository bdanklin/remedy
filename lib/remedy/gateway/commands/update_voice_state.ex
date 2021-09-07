defmodule Remedy.Gateway.Commands.UpdateVoiceState do
  @moduledoc false
  use Remedy.Schema, :payload

  embedded_schema do
    field :guild_id, :integer
    field :channel_id, :integer
    field :self_mute, :boolean
    field :self_deaf, :boolean
  end

  @defaults %{
    guild_id: 872_417_560_094_732_328,
    channel_id: 872_417_560_094_732_332,
    self_mute: false,
    self_deaf: false
  }

  def payload(state, opts \\ [])

  def payload(%Websocket{}, opts) do
    opts
    |> Enum.into(@defaults)
    |> build_payload()
  end
end
