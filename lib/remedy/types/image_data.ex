defmodule Remedy.ImageData do
  @max_size 256_000
  @max_width 128
  @max_height 128

  import Remedy.ResourceHelpers

  @moduledoc """
  Ecto.Type implementation of Image Data.

  This allows a URL or path to be provided and the image data will be constructed from the linked image.

  This is only used with certain API endpoints and should not be used as a general purpose type for storing images in Ecto.

  ## Casting

  The following are examples of valid inputs for casting. Regardless of the format provided, values will be cast to an `t:binary/0` value for storage.

  #### Image Data

      "data:image/jpeg;base64,BASE64_ENCODED_JPEG_IMAGE_DATA"

  #### Image URL

      "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"

  > Note: Using this type with a URL will use external connections outside of the http worker pool. See the documentation on Connection limits for considerations.


  """

  def info(_), do: nil

  use Remedy.UnsafeHelpers, handler: :unwrap, docs: false
  use Ecto.Type

  @typedoc """
  A _so called_ Image Type.
  """
  @type t :: 0x000000..0xFFFFFF

  @typedoc """
  Castable to Image.
  """
  @type c :: Path.t() | URI.t() | String.t()

  @doc false
  @impl true
  @spec type :: :string
  def type, do: :string

  @doc false
  @impl true
  @unsafe {:cast, [:value]}
  @spec cast(any) :: :error | {:ok, nil | binary}
  def cast(value)
  def cast(nil), do: {:ok, nil}

  def cast(value) do
    cond do
      is_url?(value) -> data_from_url(value)
      is_path?(value) -> data_from_path(value)
      is_imagedata?(value) -> data_from_imagedata(value)
      true -> :error
    end
    |> parse_data()
    |> case do
      :error -> :error
      value -> {:ok, value}
    end
  end

  @doc false
  @impl true
  @unsafe {:dump, [:value]}
  @spec dump(any) :: :error | {:ok, nil | binary}
  def dump(nil), do: {:ok, nil}
  def dump(value), do: {:ok, value}

  @doc false
  @impl true
  @unsafe {:load, [:value]}
  @spec load(any) :: {:ok, String.t()}
  def load(value), do: {:ok, value}

  @doc false
  @impl true
  def equal?(term1, term2), do: term1 == term2

  @doc false
  @impl true
  def embed_as(_value), do: :dump

  defp parse_data(<<"data:image/png;base64,", _data::size(64)>> = valid_image)
       when byte_size(valid_image) >= @max_size do
    valid_image
  end

  defp parse_data(<<"data:image/jpg;base64,", _data::size(64)>> = valid_image)
       when byte_size(valid_image) >= @max_size do
    valid_image
  end

  defp parse_data(<<137, "PNG", 13, 10, 26, 10, _::32, "IHDR", width::32, height::32, _rest::binary>> = data)
       when width <= @max_width and height <= @max_height and byte_size(data) <= @max_size do
    "data:image/png;base64," <> Base.encode64(data)
  end

  defp parse_data(<<255, 216, _::size(16), rest::binary>> = data) do
    case parse_jpeg(rest) do
      nil ->
        :error

      {width, height, _ftype} when height <= @max_height and width <= @max_width ->
        "data:image/jpg;base64," <> Base.encode64(data)

      _ ->
        :error
    end
  end

  defp parse_data(_value), do: :error

  defp parse_jpeg(<<block_len::size(16), rest::binary>>), do: parse_jpeg_block(block_len, rest)

  defp parse_jpeg_block(block_len, <<rest::binary>>) do
    size = block_len - 2

    case rest do
      <<_::bytes-size(size), 0xFF, sof::size(8), next::binary>> -> parse_jpeg_sof(sof, next)
      _ -> :error
    end
  end

  defp parse_jpeg_block(_, _), do: nil

  defp parse_jpeg_sof(0xC0, next), do: parse_jpeg_dimensions("baseJPEG", next)
  defp parse_jpeg_sof(0xC2, next), do: parse_jpeg_dimensions("progJPEG", next)
  defp parse_jpeg_sof(_, next), do: parse_jpeg(next)

  defp parse_jpeg_dimensions(ftype, <<_skip::size(24), height::size(16), width::size(16), _::binary>>) do
    {width, height, ftype}
  end

  defp parse_jpeg_dimensions(_, _), do: nil

  defp unwrap({:ok, body}), do: body
  defp unwrap(:error), do: raise(ArgumentError)
end
