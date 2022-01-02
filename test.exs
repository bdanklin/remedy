defmodule ApplicationFlags do
  use Bitwise

  defstruct GATEWAY_PRESENCE: 1 <<< 12,
            GATEWAY_PRESENCE_LIMITED: 1 <<< 13,
            GATEWAY_GUILD_MEMBERS: 1 <<< 14,
            GATEWAY_GUILD_MEMBERS_LIMITED: 1 <<< 15,
            VERIFICATION_PENDING_GUILD_LIMIT: 1 <<< 16,
            EMBEDDED: 1 <<< 17,
            GATEWAY_MESSAGE_CONTENT: 1 <<< 18,
            GATEWAY_MESSAGE_CONTENT_LIMITED: 1 <<< 19
end

defmodule Test do
  use Bitwise

  def run do
    max =
      ApplicationFlags.__struct__()
      |> Map.from_struct()
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.reduce(0, fn v, acc -> acc + v end)

    0..max
    |> Stream.filter(fn x -> x == (x &&& max) end)
    |> Enum.into([])
    |> Enum.count()
    |> IO.inspect()
  end
end

Test.run()
