defmodule Remedy.Repo do
  @moduledoc false
  use Ecto.Repo, otp_app: :fish, adapter: Etso.Adapter
end
