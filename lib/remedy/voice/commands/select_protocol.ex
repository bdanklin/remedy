defmodule Remedy.Voice.Commands.SelectProtocol do
  defstruct protocol: "udp",
            data: %{
              address: "",
              port: "",
              mode: ""
            }
end
