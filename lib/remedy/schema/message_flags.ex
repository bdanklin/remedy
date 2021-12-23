defmodule Remedy.Schema.MessageFlags do
  @moduledoc """

  ## Values

  - `1 << 0`  - `:CROSSPOSTED`
  - `1 << 1`  - `:IS_CROSSPOST`
  - `1 << 2`  - `:SUPRESS_EMBEDS`
  - `1 << 3`  - `:SOURCE_MESSAGE_DELETED`
  - `1 << 4`  - `:URGENT`
  - `1 << 5`  - `:HAS_THREAD`
  - `1 << 6`  - `:EPHEMERAL`
  - `1 << 7`  - `:LOADING`

  """

  use Remedy.Flag

  defstruct CROSSPOSTED: 1 <<< 0,
            IS_CROSSPOST: 1 <<< 1,
            SUPPRESS_EMBEDS: 1 <<< 2,
            SOURCE_MESSAGE_DELETED: 1 <<< 3,
            URGENT: 1 <<< 4,
            HAS_THREAD: 1 <<< 5,
            EPHEMERAL: 1 <<< 6,
            LOADING: 1 <<< 7
end
