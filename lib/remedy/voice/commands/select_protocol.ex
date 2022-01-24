defmodule Remedy.Voice.Commands.SelectProtocol do
  @moduledoc false

  defstruct protocol: "udp",
            data: %{
              address: "",
              port: "",
              mode: ""
            }
end
