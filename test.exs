defmodule Solve do
  def floop(_, _)
  def floop(0, _), do: [[]]
  def floop(_, []), do: []

  def floop(m, [h | t]) do
    IO.inspect("#{inspect(m)}, #{inspect(h)}, #{inspect(t)}")
    for l <- floop(m - 1, t) do
      [h | l]) ++ floop(m, t)
    end
  end
end

k = Enum.random(1..20)
n = Enum.random(1..(k - 1))
Solve.floop(n, k)
