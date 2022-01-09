defmodule Solve do
  def run do
    File.read!("remedy.png")
    |> cast()
  end
end

Solve.run()
