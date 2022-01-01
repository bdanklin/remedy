defmodule Remedy do
  @moduledoc """
  This is the documentation for the Remedy library.
  """
  alias Remedy.Schema.{Channel, Emoji, Guild, Message, User, Role}

  @doc """
  Format various types to a "mention"


  """
  def mention(type, format \\ nil)

  def mention(%User{id: user_id}, :nickname) do
    "<@#{user_id}>"
  end

  def mention(%User{id: user_id}, _format) do
    "<@!#{user_id}>"
  end

  def mention(%Channel{id: channel_id}, _format) do
    "<\# #{channel_id}>"
  end

  def mention(%Role{id: role_id}, _format) do
    "<@&#{role_id}>"
  end

  def mention(%Emoji{name: emoji_name, id: nil}, _format) do
    "#{emoji_name}"
  end

  def mention(%Emoji{id: emoji_id, animated: false}, _format) do
    "<:#{emoji_id}>"
  end

  def mention(%Emoji{id: emoji_id, name: emoji_name, animated: true}, _format) do
    "<a:#{emoji_name}:#{emoji_id}>"
  end

  def link(type, _format)

  def link(%Message{id: message_id, channel_id: channel_id, guild_id: guild_id}, _format) do
    "<https://discord.com/channels/#{guild_id}/#{channel_id}/#{message_id}>"
  end

  def link(%Channel{id: channel_id, guild_id: guild_id}, _format) do
    "<https://discord.com/channels/#{guild_id}/#{channel_id}>"
  end

  def link(%Guild{id: guild_id}, _format) do
    "<https://discord.com/channels/#{guild_id}>"
  end
end
