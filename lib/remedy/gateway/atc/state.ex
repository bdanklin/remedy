defmodule Remedy.Gateway.ATC.State do
  @moduledoc false
  #############################################################################
  ## Air Traffic Control.
  ##
  ## Allow one shard to connect per 5s.
  defstruct bucket: :atc,
            concurrency: 1

  @connection_time 5000

  def new(args) do
    %__MODULE__{concurrency: args[:concurrency] || 1}
  end

  def handle_request_connection(%__MODULE__{bucket: bucket, concurrency: concurrency} = state) do
    with {_count, 0, ms_to_next_bucket, _created_at, _updated_at} <-
           ExRated.inspect_bucket(bucket, @connection_time, concurrency) do
      try_again_in(ms_to_next_bucket, state)
    else
      {_count, _count_remaining, _ms_to_next_bucket, _created_at, _updated_at} ->
        increment_rate_limit(state)
    end
  end

  defp try_again_in(ms_to_next_bucket, state) do
    Process.sleep(ms_to_next_bucket)
    handle_request_connection(state)
  end

  defp increment_rate_limit(%__MODULE__{bucket: bucket, concurrency: concurrency} = state) do
    case ExRated.check_rate(bucket, @connection_time, concurrency) do
      {:ok, _count} -> :ok
      {:error, _limit} -> handle_request_connection(state)
    end
  end
end
