defmodule Remedy.DevConsumerSupervisor do
  @moduledoc false
  use Supervisor
  alias Remedy.DevConsumer

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      DevConsumer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Remedy.DevConsumer do
  @moduledoc false
  require Logger
  use Remedy.Consumer

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({_event, _payload, _socket}) do
    :noop
  end
end
