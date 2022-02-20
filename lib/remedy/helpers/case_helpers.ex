defmodule Remedy.CaseHelpers do
  @moduledoc """
  Functions within this module take heavy inspiration from the [`Recase`](https://hexdocs.pm/recase/Recase.html#content) library with dead weight that we do not require cut out.
  """

  @doc """
  converts a string or atom to pascal case.

  ## Examples

      iex> Remedy.CaseHelpers.to_pascal("hello world")
      "HelloWorld"

      iex> Remedy.CaseHelpers.to_pascal(:case_helpers)
      CaseHelpers

  """

  def to_pascal(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> to_pascal()
    |> String.to_atom()
  end

  def to_pascal(value) when is_binary(value),
    do: rejoin(value, separator: "", case: :title)

  @doc """
  Convert a string to title case.
  """
  def to_title(value) when is_binary(value),
    do: rejoin(value, separator: " ", case: :title)

  def to_sentence(value) when is_binary(value) do
    with <<char::utf8, rest::binary>> <-
           rejoin(value, separator: " ", case: :down),
         do: String.upcase(<<char::utf8>>) <> rest
  end

  @delimiters [?\s, ?\n, ?\t, ?_, ?., ?-, ?#, ??, ?!]

  defp rejoin(input, opts) when is_binary(input) do
    mapper =
      case Keyword.get(opts, :case, :down) do
        :down ->
          &String.downcase/1

        :title ->
          fn <<char::utf8, rest::binary>> ->
            String.upcase(<<char::utf8>>) <> String.downcase(rest)
          end

        :up ->
          &String.upcase/1

        _ ->
          & &1
      end

    input
    |> do_split()
    |> Enum.map(mapper)
    |> Enum.join(Keyword.get(opts, :separator, ?_))
  end

  defp do_split(string, acc \\ {"", []})

  defp do_split("", {"", acc}),
    do: Enum.reverse(acc)

  defp do_split("", {curr, acc}),
    do: do_split("", {"", [curr | acc]})

  Enum.each(@delimiters, fn delim ->
    defp do_split(<<unquote(delim)::utf8, rest::binary>>, {"", acc}),
      do: do_split(rest, {"", acc})

    defp do_split(<<unquote(delim), rest::binary>>, {curr, acc}),
      do: do_split(rest, {"", [curr | acc]})
  end)

  Enum.each(?A..?Z, fn char ->
    defp do_split(<<unquote(char), rest::binary>>, {"", acc}),
      do: do_split(rest, {<<unquote(char)::utf8>>, acc})

    defp do_split(<<unquote(char), rest::binary>>, {curr, acc}) do
      <<c::utf8, _::binary>> = String.reverse(curr)

      if c in ?A..?Z do
        do_split(rest, {curr <> <<unquote(char)::utf8>>, acc})
      else
        do_split(rest, {<<unquote(char)::utf8>>, [curr | acc]})
      end
    end
  end)

  [32..64, 91..127]
  |> Enum.map(&Enum.to_list/1)
  |> Enum.reduce(&Kernel.++/2)
  |> Kernel.--(@delimiters)
  |> Enum.each(fn char ->
    defp do_split(<<unquote(char)::utf8, rest::binary>>, {"", acc}),
      do: do_split(rest, {<<unquote(char)::utf8>>, acc})

    defp do_split(<<unquote(char), rest::binary>>, {curr, acc}),
      do: do_split(rest, {curr <> <<unquote(char)::utf8>>, acc})
  end)

  defp do_split(<<char::utf8, rest::binary>>, {"", acc}),
    do: do_split(rest, {<<char::utf8>>, acc})

  defp do_split(<<char::utf8, rest::binary>>, {curr, acc}) do
    if Regex.match?(~r/(?<!\p{Lu})\p{Lu}/u, <<char::utf8>>) do
      do_split(rest, {<<char::utf8>>, [curr | acc]})
    else
      do_split(rest, {curr <> <<char::utf8>>, acc})
    end
  end
end
