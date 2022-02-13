defmodule Remedy.MalformedRouteError do
  @moduledoc """
  Raised when an API route cannot be constructed for the given request.

  This exception indicates an error within Remedy.

  Please report it to: https://github.com/bdanklin/remedy/issues
  """
  defexception message: nil
end
