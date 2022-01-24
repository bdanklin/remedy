defmodule Remedy.URL do
  @moduledoc """
  `Ecto.Type` implementation for URLs.

  Validates every url using regex.
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
    value
    |> validate_url()
    |> case do
      true -> {:ok, clean_string(value)}
      false -> :error
    end
  end

  @spec dump(any) :: {:ok, t}
  @doc false
  @impl true
  def dump(nil), do: {:ok, nil}

  def dump(value) do
    {:ok, clean_string(value)}
  end

  @spec load(any) :: {:ok, t}
  @doc false
  @impl true
  def load(value) do
    {:ok, value}
  end

  @doc false
  @impl true
  def embed_as(_), do: :self

  @doc false
  @impl true
  def equal?(term1, term2), do: term1 == term2

  defp validate_url(url) do
    regex =
      ~r/(?:https?|ftp):\/\/(www\\.)?[-a-zA-Z0-9@:%._\+~#=]{2,255}\.[a-z]{2,9}\b([-a-zA-Z0-9@:%_+.,~#?!&>\/\/=]*)$/

    Regex.match?(regex, url)
  end

  defp clean_string(value) do
    value |> to_string() |> String.trim()
  end
end
