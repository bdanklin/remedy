defmodule Remedy.Consumer.Metadata do
  @moduledoc """
  Contains information about the gateway event.

  Immediately prior to the event being processed in your consumer the %WSState{} struct that was passed along with it through the pipeline will be converted into a `%Metadata{}` struct. This will convert the data into something more palatable. Such as how long the request took to process, which shard it came from, etc.
  """
  @type t :: %__MODULE__{
          gateway: :voice | :gateway,
          time_in_pipeline: integer(),
          shard: integer() | nil,
          shard_latency: integer(),
          dx_dt: integer()
        }
  defstruct [:shard, :gateway, :time_in_pipeline, :shard_latency, :dx_dt]
end
