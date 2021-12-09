defmodule Remedy.Commands do
  require Logger
  use Remedy.Schema

  alias Remedy.Schema.Command

  embedded_schema do
    embeds_one :command, Command
    field :mod, :binary
    field :fun, :binary
    field :args, :binary
  end

  def register(%Command{} = command, {mod, fun, args_from_interaction}) do
    ## register the command via rest api
    ## store command in ets
  end

  def register(%Command{} = command, anonymous_fn) do
    ## register the command via rest api
    ## store command in ets
  end

  #  def invoke({:INTERACTION_CREATE, interaction, socket}) do
  #    with {:ok, command} <- check_interaction(interaction) do
  #      IO.inspect("hi")
  #    end
  #  end

  def invoke(_arg), do: :noop

  defp register_command_with_discord(%{guild_id: guild_id} = command) do
    Remedy.API.create_guild_application_command(guild_id, command)
  end
end
