defmodule Remedy.TokenHelpers do
  @doc """
  Convert the token to its Snowflake id, aka the application id.
  """
  def to_snowflake(token) do
    token
    |> String.split(".")
    |> List.first()
    |> Base.decode64!()
    |> String.to_integer()
  end
end
