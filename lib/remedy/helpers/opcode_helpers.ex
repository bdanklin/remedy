defmodule Remedy.OpcodeHelpers do
  @moduledoc false

  @doc false
  defguard is_op_code(code)
           when code in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 999]

  @doc false
  defguard is_op_event(event)
           when event in [
                  :DISPATCH,
                  :HEARTBEAT,
                  :IDENTIFY,
                  :STATUS_UPDATE,
                  :VOICE_STATUS_UPDATE,
                  :VOICE_SERVER_PING,
                  :RESUME,
                  :RECONNECT,
                  :REQUEST_GUILD_MEMBERS,
                  :INVALID_SESSION,
                  :HELLO,
                  :HEARTBEAT_ACK,
                  :SYNC_GUILD,
                  :SYNC_CALL
                ]

  @opcodes %{
    DISPATCH: 0,
    HEARTBEAT: 1,
    IDENTIFY: 2,
    STATUS_UPDATE: 3,
    VOICE_STATUS_UPDATE: 4,
    VOICE_SERVER_PING: 5,
    RESUME: 6,
    RECONNECT: 7,
    REQUEST_GUILD_MEMBERS: 8,
    INVALID_SESSION: 9,
    HELLO: 10,
    HEARTBEAT_ACK: 11,
    SYNC_GUILD: 12,
    SYNC_CALL: 13,
    OPCODE_HELPERS: 999
  }

  @type event ::
          :DISPATCH
          | :HEARTBEAT
          | :IDENTIFY
          | :STATUS_UPDATE
          | :VOICE_STATUS_UPDATE
          | :VOICE_SERVER_PING
          | :RESUME
          | :RECONNECT
          | :REQUEST_GUILD_MEMBERS
          | :INVALID_SESSION
          | :HELLO
          | :HEARTBEAT_ACK
          | :SYNC_GUILD
          | :SYNC_CALL

  @doc """
  Convert the event to its Module form

  ## Examples

      iex> Remedy.OpcodeHelpers.mod_from_event(:DISPATCH)
      Dispatch

  """
  def mod_from_event(k) do
    to_string(k)
    |> String.downcase()
    |> Recase.to_pascal()
    |> List.wrap()
    |> Module.concat()
  end

  @doc """
  Convert the Opcode to its Module form

  ## Examples

      iex> Remedy.OpcodeHelpers.mod_from_op(999)
      OpcodeHelpers

  """
  def mod_from_op(opcode) when is_op_code(opcode) do
    event_from_op(opcode)
    |> Atom.to_string()
    |> String.downcase()
    |> Recase.to_pascal()
    |> List.wrap()
    |> Module.concat()
  end

  @doc """
  Convert the event to its Opcode form

  ## Examples

      iex> Remedy.OpcodeHelpers.op_from_event(:DISPATCH)
      0

  """
  def op_from_event(event) do
    Map.get(@opcodes, event)
  end

  @doc false
  def op_from_mod do
    event_from_mod() |> op_from_event()
  end

  @doc false
  def op_from_mod(module) do
    event_from_mod(module) |> op_from_event()
  end

  @doc false
  def event_from_mod(module) do
    module
    |> Module.split()
    |> List.last()
    |> Recase.to_snake()
    |> String.upcase()
    |> String.to_atom()
  end

  @doc false
  def event_from_mod do
    __MODULE__
    |> Module.split()
    |> List.last()
    |> Recase.to_snake()
    |> String.upcase()
    |> String.to_atom()
  end

  @doc false
  def event_from_op(opcode) do
    for {k, v} <- @opcodes, into: [] do
      if v == opcode do
        k
      end
    end
    |> Enum.reject(&is_nil/1)
    |> List.first()
  end

  @doc false
  def discord_epoch, do: 1_420_070_400_000

  @doc false
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

  @doc false
  def voice_opcode_from_name(event) do
    voice_opcodes()[event]
  end

  @doc false
  def atom_from_voice_opcode(opcode) do
    {k, _} = Enum.find(voice_opcodes(), fn {_, v} -> v == opcode end)
    k |> String.downcase() |> String.to_atom()
  end
end
