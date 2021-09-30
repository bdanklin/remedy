defmodule Remedy.API.RestResponse do
  @moduledoc false

  @type status :: integer() | nil
  @type headers :: keyword
  @type body :: term

  @type t :: %__MODULE__{
          status: status,
          headers: headers,
          body: body
        }

  defstruct [
    :status,
    :headers,
    :body
  ]
end
