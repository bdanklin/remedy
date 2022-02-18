defmodule Remedy.Buffer.Left.State do
  @moduledoc false
  #############################################################################
  ## events: any events to be re sent
  ## demand: any pending demand (probably always zero)
  ## hash: a hash array mapped trie (probably) that has keys of
  ##   :erlang.term_to_binary of {event, payload} for events currently being
  ##   processed. the value is the %Broadway.Message{} of the event
  ##
  ## Events that arrive are checked against the hash to see if they are already
  ## in the pipeline. This stops us from processing the same event twice in the
  ## case of starting overlapping shards before the old shards are closed.
  defstruct queue: :queue.new(),
            hash: %{},
            demand: 0

  def handle_ingest(%__MODULE__{hash: hash, queue: queue} = state, {event, payload, socket}) do
    if Map.has_key?(hash, {event, payload}) do
      state
    else
      message = %Broadway.Message{
        acknowledger: {
          Remedy.Buffer.Left,
          {socket.shard, socket.heartbeat, socket.payload_sequence},
          data: payload
        },
        metadata: %{event: event, payload: payload, socket: socket},
        data: payload
      }

      %__MODULE__{state | hash: Map.put_new(hash, {event, payload}, socket), queue: :queue.in(message, queue)}
    end
    |> dispatch_events()
  end

  def handle_ack(%__MODULE__{hash: hash, queue: queue} = state, {_ack_ref, successful, failed}) do
    hash =
      unless successful == [] do
        Enum.map(successful, fn message -> {message.metadata.event, message.metadata.payload} end)
        |> then(&Map.drop(state, &1))
      else
        hash
      end

    case failed do
      [] ->
        state

      failed ->
        failed
        |> case do
          [] -> []
          [_ | _] = failed -> Enum.map(failed, fn message -> message.data.hash_key end)
        end
        |> then(&Map.take(hash, &1))
        |> Enum.reduce(queue, fn
          {_k, message}, queue -> :queue.in(message, queue)
        end)
        |> then(&Map.put(state, :queue, &1))
    end
    |> dispatch_events()
  end

  def handle_demand(%__MODULE__{} = state, _) do
    state
    |> dispatch_events()
  end

  defp dispatch_events(state, events \\ [])

  defp dispatch_events(%__MODULE__{queue: {[], []}} = state, events) do
    {:noreply, Enum.reverse(events), state}
  end

  defp dispatch_events(%__MODULE__{queue: queue} = state, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        %__MODULE__{state | queue: queue}
        |> dispatch_events([event | events])

      {:empty, _queue} ->
        state
        |> dispatch_events(events)
    end
  end
end
