defmodule Remedy.Constants do
  @moduledoc false

  def base_url,
    do: "https://discord.com/api/v9"

  def discord_epoch, do: 1_420_070_400_000

  # Voice Gateway has a separate set of opcodes
  def voice_opcodes do
    %{
      "IDENTIFY" => 0,
      "SELECT_PROTOCOL" => 1,
      "READY" => 2,
      "HEARTBEAT" => 3,
      "SESSION_DESCRIPTION" => 4,
      "SPEAKING" => 5,
      "HEARTBEAT_ACK" => 6,
      "RESUME" => 7,
      "HELLO" => 8,
      "RESUMED" => 9,
      "UNDOCUMENTED_10" => 10,
      "UNDOCUMENTED_11" => 11,
      "CLIENT_CONNECT" => 12,
      "CLIENT_DISCONNECT" => 13,
      "CODEC_INFO" => 14
    }
  end

  def voice_opcode_from_name(event) do
    voice_opcodes()[event]
  end

  def atom_from_voice_opcode(opcode) do
    {k, _} = Enum.find(voice_opcodes(), fn {_, v} -> v == opcode end)
    k |> String.downcase() |> String.to_atom()
  end
end
