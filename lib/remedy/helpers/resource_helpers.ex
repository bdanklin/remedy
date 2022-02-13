defmodule Remedy.ResourceHelpers do
  @moduledoc """
  Resource Helper Functions
  """
  def url_regex do
    ~r/(?:https?|ftp):\/\/(www\\.)?[-a-zA-Z0-9@:%._\+~#=]{2,255}\.[a-z]{2,9}\b([-a-zA-Z0-9@:%_+.,~#?!&>\/\/=]*)$/
  end

  def path_regex do
    ~r/^[A-Z]:(\\[^\\]+)+\\?$|^\/?([^\/]+\/)+/
  end

  def is_imagedata?("image/" <> _rest), do: true
  def is_imagedata?(_no), do: false

  def is_url?(value), do: String.match?(value, url_regex())
  def is_path?(value), do: value |> Path.expand() |> String.match?(path_regex())

  def data_from_path(path), do: File.read(path)

  def data_from_url(url) do
    url
    |> :erlang.binary_to_list()
    |> :httpc.request()
    |> elem(1)
    |> elem(2)
    |> :erlang.list_to_binary()
  end

  def data_from_imagedata(<<"image/png;base64,", data::binary>>), do: Base.decode64(data)
  def data_from_imagedata(<<"image/jpg;base64,", data::binary>>), do: Base.decode64(data)
end
