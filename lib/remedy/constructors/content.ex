defmodule Remedy.Content do
  @moduledoc """
  Functions for assisting with message content.
  """
  alias Remedy.Schema.{Channel, Emoji, Guild, Message, User, Role}

  @doc """
  Mentions the given object.

  ## Examples

      iex> mention(%User{id: 883307747305725972})
      "<@883307747305725972>"

      iex> mention(%Role{id: 883307747305725972})
      "<@&883307747305725972>"

      iex> mention(%Channel{id: 883307747305725972})
      "<#883307747305725972>"

  """

  def mention(type)
  def mention(%User{id: user_id}), do: "<@!#{user_id}>"
  def mention(%Channel{id: channel_id}), do: "<\##{channel_id}>"
  def mention(%Role{id: role_id}), do: "<@&#{role_id}>"
  def mention(%Emoji{name: emoji_name, require_colons: true, id: nil}), do: ":#{emoji_name}:"
  def mention(%Emoji{name: emoji_name, id: nil}), do: "#{emoji_name}"
  def mention(%Emoji{id: emoji_id, animated: false}), do: "<:#{emoji_id}>"
  def mention(%Emoji{id: emoji_id, name: emoji_name, animated: true}), do: "<a:#{emoji_name}:#{emoji_id}>"

  def link(type)
  def link(%Channel{id: channel_id, guild_id: guild_id}), do: "#{guild_id}/#{channel_id}" |> encode()
  def link(%Guild{id: guild_id}), do: "#{guild_id}" |> encode()

  def link(%Message{id: message_id, channel_id: channel_id, guild_id: guild_id}),
    do: "#{guild_id}/#{channel_id}/#{message_id}" |> encode()

  defp encode(post), do: "https://discord.com/channels/" <> "#{post}"
end
