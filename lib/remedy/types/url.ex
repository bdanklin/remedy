defmodule Remedy.URL do
  import Remedy.ResourceHelpers, only: [is_url?: 1]

  @moduledoc """
  `Ecto.Type` implementation for URLs.
  """
  use Ecto.Type

  @typedoc """
  A URL Type.
  """
  @type t() :: String.t() | nil

  @typedoc """
  Castable to URL.
  """
  @type c() :: t() | String.t()

  @doc false
  @impl true
  @spec type :: :string
  def type, do: :string

  @spec cast(binary) :: :error | {:ok, t}
  @doc false
  @impl true
  def cast(value)

  def cast(value) do
    if is_url?(value) do
      {:ok, String.trim(value)}
    else
      :error
    end
  end

  @doc false
  @impl true
  def dump(nil), do: {:ok, nil}
  def dump(value), do: {:ok, value}

  @doc false
  @impl true
  def load(value), do: {:ok, value}

  @doc false
  @impl true
  def embed_as(_), do: :self

  @doc false
  @impl true
  def equal?(term1, term2), do: term1 == term2
end
