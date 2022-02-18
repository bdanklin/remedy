defmodule Remedy.Buffer.Right.State do
  @moduledoc false

  #############################################################################
  ## All Functions accept a %__MODULE__{} and return a %__MODULE__{}
  ##
  ## Kind of flakey because we cant use a normal GenStage subscription.
  ##
  ## TODO: Could inject this into the Broadway to start after the producer

  require Logger

  @type t :: %__MODULE__{
          queue: term,
          broadway: {module :: atom},
          hold: boolean,
          hold_timer: reference() | nil,
          hold_since: integer | nil
        }

  defstruct hold: true,
            hold_timer: nil,
            hold_since: nil,
            queue: :queue.new(),
            broadway: Remedy.Dispatch.Pipeline

  def new do
    Logger.debug("BUFFER INITIALIZED...")

    %__MODULE__{
      hold_since: now(),
      hold_timer: Process.send_after(self(), :holding, 50)
    }
  end

  #############################################################################
  ## Start pushing events as soon as we can.

  #############################################################################
  ## Heartbeat function to log warnings when the Out Buffer is on hold.
  ##
  ## No longer on hold - Events are dispatched.
  ## Still on hold - Emit logs and check back

  def handle_holding(%__MODULE__{broadway: broadway} = state) do
    if broadway in Broadway.all_running() do
      state
      |> stop_holding()
      |> dispatch_events()
    else
      keep_holding(state)
    end
  end

  @spec handle_holding(t()) :: t()
  def handle_holding(%__MODULE__{hold: false} = state) do
    state
    |> dispatch_events()
  end

  def handle_holding(%__MODULE__{queue: {[], []}, hold: true} = state) do
    state
    |> keep_holding()
  end

  def handle_holding(%__MODULE__{queue: queue, hold: true, hold_since: hold_since} = state) do
    queue_length = :queue.len(queue)
    since = now() - hold_since
    Logger.warn("BUFFER_OUT: HOLDING #{queue_length} EVENTS...ON HOLD FOR: #{since}ms")

    state
    |> keep_holding()
  end

  #############################################################################
  ## Immediately put the Buffer on hold.
  ##
  ## This should only be done when the Broadway Pipeline needs to be restarted
  ## due to changing topology or some critical error.

  @spec handle_sync_hold_push(t()) :: t()
  def handle_sync_hold_push(%__MODULE__{} = state) do
    %__MODULE__{state | hold: true, hold_since: now()}
    |> keep_holding()
  end

  ############################################################################
  ## Hold Functions

  defp keep_holding(state) do
    %__MODULE__{state | hold_timer: Process.send_after(self(), :holding, 10)}
  end

  defp stop_holding(%__MODULE__{} = state) do
    %__MODULE__{state | hold: false, hold_since: nil, hold_timer: nil}
  end

  #############################################################################

  @spec handle_events(t(), any) :: t()
  def handle_events(%__MODULE__{} = state, events) do
    state
    |> dispatch_events(events)
  end

  defp dispatch_events(state, events \\ [])

  defp dispatch_events(%__MODULE__{hold: true} = state, []) do
    state
  end

  ## If
  defp dispatch_events(%__MODULE__{hold: true, queue: queue} = state, events) do
    queue =
      Enum.reduce(events, queue, fn
        event, queue -> :queue.in(event, queue)
      end)

    %__MODULE__{state | queue: queue}
    |> dispatch_events()
  end

  ## Empty internal queue, not on hold, no events, nothing to see here.
  defp dispatch_events(%__MODULE__{hold: false, queue: {[], []}} = state, []) do
    state
  end

  ## Empty internal queue, not on hold, slap those events forward
  defp dispatch_events(%__MODULE__{hold: false, queue: {[], []}, broadway: broadway} = state, events) do
    with events <- Enum.reverse(events),
         :ok <- Broadway.push_messages(broadway, events) do
      state
      |> dispatch_events()
    end
  end

  ## If we have a queue and not on hold, pull the events out and come back ^
  defp dispatch_events(%__MODULE__{hold: false, queue: queue} = state, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        %__MODULE__{state | queue: queue}
        |> dispatch_events([event | events])

      {:empty, _queue} ->
        state
        |> dispatch_events(events)
    end
  end

  ############################################################################
  ## Now in unix_ms

  defp now do
    DateTime.now!("Etc/UTC", :millisecond)
    |> DateTime.to_unix()
  end
end
