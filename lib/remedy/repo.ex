defmodule Remedy.Repo do
  @moduledoc false
  use Ecto.Repo, otp_app: :remedy, adapter: Etso.Adapter
end
