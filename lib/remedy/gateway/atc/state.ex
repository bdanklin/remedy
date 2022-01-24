defmodule Remedy.Gateway.ATC.State do
  defstruct bucket: :atc,
            concurrency: 1

  @connection_time 5000

  def new(args) do
    %__MODULE__{concurrency: args[:concurrency] || 1}
  end

  def check_rate_limit(%__MODULE__{bucket: bucket, concurrency: concurrency} = state) do
    case ExRated.inspect_bucket(bucket, @connection_time, concurrency) do
      {_count, 0, ms_to_next_bucket, _created_at, _updated_at} ->
        try_again_in(ms_to_next_bucket, state)

      {_count, _count_remaining, _ms_to_next_bucket, _created_at, _updated_at} ->
        :ok
    end
  end

  def increment_rate_limit(%__MODULE__{bucket: bucket, concurrency: concurrency} = state) do
    case ExRated.check_rate(bucket, @connection_time, concurrency) do
      {:ok, _count} -> :ok
      {:error, _limit} -> check_rate_limit(state)
    end
  end

  defp try_again_in(ms_to_next_bucket, state) do
    Process.sleep(ms_to_next_bucket)
    check_rate_limit(state)
  end
end
