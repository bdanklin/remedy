defmodule Fish.Repo do
  use Ecto.Repo, otp_app: :fish, adapter: Etso.Adapter
end
