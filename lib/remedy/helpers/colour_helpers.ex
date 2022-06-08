defmodule Remedy.ColourHelpers do
  @moduledoc """
  Colour Helper Functions.

  """

  @type rgb_tuple :: {0..0xFF, 0..0xFF, 0..0xFF}

  @type hex_binary :: String.t()

  @type hex_integer :: 0..0xFFFFFF

  @doc false
  @doc section: :guards
  defguard is_component(r) when r in 0..0xFF

  @doc """
  Converts a colour to a tuple of {red, green, blue}
  """
  @doc since: "0.6.8"
  @spec to_rgb(rgb_tuple | hex_binary | hex_integer) :: rgb_tuple
  def to_rgb({r, g, b}) when r in 0..0xFF and g in 0..0xFF and b in 0..0xFF do
    {r, g, b}
  end

  def to_rgb(integer) when is_integer(integer) and integer in 0..0xFFFFFF do
    <<r, g, b>> = Integer.to_string(integer, 16) |> Base.decode16!()
    {r, g, b}
  end

  def to_rgb(hex) when is_binary(hex) do
    case valid_hex?(hex) do
      true ->
        <<r, g, b>> = parse_hex(hex) |> Base.decode16!()
        {r, g, b}

      false ->
        :error
    end
  end

  @doc """
  Convert a value to its HEX representation.

  """
  def to_hex({r, g, b} = rgb) when r in 0..0xFF and g in 0..0xFF and b in 0..0xFF do
    rgb
    |> Tuple.to_list()
    |> Enum.map(&Integer.to_string(&1, 16))
    |> to_string()
  end

  def to_hex(0) do
    "000000"
  end

  def to_hex(integer) when is_integer(integer) and integer in 0..0xFFFFFF do
    Integer.to_string(integer, 16)
  end

  def to_hex(hex) when is_binary(hex) do
    case valid_hex?(hex) do
      true ->
        hex

      false ->
        :error
    end
  end

  @doc """
  Convert a value to its integer representation.

  """

  def to_integer(nil) do
    nil
  end

  def to_integer(integer) when is_integer(integer) and integer in 0..0xFFFFFF do
    integer
  end

  def to_integer({r, g, b}) when r in 0..0xFF and g in 0..0xFF and b in 0..0xFF do
    r * 0x10000 + g * 0x100 + b
  end

  def to_integer(hex) when is_binary(hex) do
    case valid_hex?(hex) do
      true ->
        {integer, ""} = parse_hex(hex) |> Integer.parse(16)

        integer

      false ->
        :error
    end
  end

  defp valid_hex?(hex) when is_binary(hex) and byte_size(hex) in [3, 4, 6, 7] do
    hex
    |> String.trim_leading("#")
    |> String.upcase()
    |> String.match?(~r/^([0-9A-F]{3}){1,2}$/)
  end

  defp parse_hex(hex) when is_binary(hex) and byte_size(hex) in [3, 4, 6, 7] do
    hex
    |> String.trim_leading("#")
    |> String.upcase()
  end
end

defmodule Remedy.ColourHelpers.Palette do
  @moduledoc """
  Basic colour palette.

  ![image](https://user-images.githubusercontent.com/34633373/155273197-df056917-2b8c-4f0b-a674-4966069dcc3a.png)
  """

  @danger "#FE625D"
  @spec danger :: <<_::56>>
  @doc ~s(Danger #{@danger}
  {: style="color: #{@danger};"})
  def danger, do: @danger

  @warning "#FFD866"
  @spec warning :: <<_::56>>
  @doc ~s(Warning #{@warning}
  {: style="color: #{@warning};"})
  def warning, do: @warning

  @success "#A9DC76"
  @spec success :: <<_::56>>
  @doc ~s(Success #{@success}
  {: style="color: #{@success};"})
  def success, do: @success

  @neutral "#78DCE8"
  @spec neutral :: <<_::56>>
  @doc ~s(Neutral #{@neutral}
  {: style="color: #{@neutral};"})
  def neutral, do: @neutral

  @info "#AB9DF2"
  @spec info :: <<_::56>>
  @doc ~s(Info #{@info}
  {: style="color: #{@info};"})
  def info, do: @info

  @dark "#2C292D"
  @spec dark :: <<_::56>>
  @doc ~s(Dark #{@dark}
  {: style="color: #{@dark};"})
  def dark, do: @dark

  @light "#FDF9F3"
  @spec light :: <<_::56>>
  @doc ~s(Light #{@light}
  {: style="color: #{@light};"})
  def light, do: @light
end
