defmodule Remedy.DummyConsumerSupervisor do
  use Supervisor
  alias Remedy.DummyConsumer

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      DummyConsumer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Remedy.DummyConsumer do
  require Logger
  use Remedy.Consumer

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({event, _payload, _socket}) do
    Logger.warn("#{inspect(event)}")
  end
end
