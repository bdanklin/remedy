defmodule Remedy.CDN do
  @moduledoc """
  Discord CDN functions.
  """

  @cdn "https://cdn.discordapp.com"

  def avatar(id, avatar)

  def avatar(id, avatar) do
    "#{@cdn}/avatars/#{id}/#{avatar}.png"
    |> URI.encode()
  end

  def animated_avatar(id, avatar) do
    "#{@cdn}/avatars/#{id}/#{avatar}.gif"
    |> URI.encode()
  end

  def embed_avatar(image_name) do
    "#{@cdn}/embed/avatars/#{image_name}.png"
    |> URI.encode()
  end

  def emoji(id) do
    "#{@cdn}/emojis/#{id}.png"
    |> URI.encode()
  end

  def animated_emoji(id) do
    "#{@cdn}/emojis/#{id}.gif"
    |> URI.encode()
  end

  def icon(id, icon) do
    "#{@cdn}/icons/#{id}/#{icon}.png"
    |> URI.encode()
  end

  def splash(id, splash) do
    "#{@cdn}/splashes/#{id}/#{splash}.png"
    |> URI.encode()
  end
end
