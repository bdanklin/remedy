defmodule Remedy.Gateway.Dispatch.UserUpdate do
  @moduledoc """
  Dispatched when a new guild channel is created, relevant to the current user.

  ## Payload:

  - %Remedy.Schema.Guild{}.

  """

  alias Remedy.Schema.User

  def handle({event, payload, socket}) do
    {event,
     payload
     |> User.new(), socket}
  end

  ### If bot ID. update bot
  # def handle({event, payload, socket}) do
  #   {event,
  #    payload
  #    |> Integration.new(), socket}
  # end
end
