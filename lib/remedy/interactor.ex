defmodule Remedy.Interactor do
  @moduledoc false

  ## Interactions are the method of communication between user actions and your application.
  ##
  ## This module provides conveniences around generating and matching interactions.
  ##
  ## Interactions can be triggered by a number of different events.
  ##
  ## - Message Components ( Buttons, Dropdowns, etc )
  ## - Slash commands
  ## - Context commands
  ##
  ## How you respond to these is entirely up to you. The issue with commands and interactions comes down to the duality of creating the method for the interaction to take place, as well as being able to match on that interaction.
  ##
  ## For example. If your applicaiton has a single command described as such:
  ##
  ##     %Remedy.Schema.Command{
  ##       type: 2,
  ##       name: "promote_user",
  ##       description: "Promote a user to admin"
  ##     }
  ##
  ## Then pattern matching on this command in your `Remedy.Consumer` is as easy as
  ##
  ##     def handle_event(:INTERACTION_CREATE, %{data: %{type: 2, name: "promote_user"}}) do
  ##       # ...
  ##     end
  ##
  ## Herein lies the issue, the interaction response must be hardcoded to the consumer. But the elements that trigger that interaction can be created at any time. Keeping both of them in sync is non trivial and error prone.
  ##
  ## Using the functions within this module will assist you to implement components and commands, and automatically match on the response interactions.
  ##
  ## """

  use Remedy.Schema

  schema "interactors" do
    embeds_one :component, Component
  end

  def ingest(_interaction) do
    :ok
  end
end
