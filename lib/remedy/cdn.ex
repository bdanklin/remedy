defmodule Remedy.CDN do
  @moduledoc """
  Discord CDN interface.

  Storing images and other assets can be painful, use this module to retreive assets from the discord cdn rather than storing them.

  Each function takes the required parameters to directly access a resource.

  > Some functions may directly take a struct, for example `%User{} |> CDN.user_avatar()`. But these are undocumented.

  ## Format

  All images are returned as either a `.png` or a `.gif` if the asset is animated. This is done automatically.

  ## Size
  """
  @cdn "https://cdn.discordapp.com"

  def custom_emoji(id, size \\ nil) do
    "/emojis/#{id}"
    |> encode(id, size)
  end

  def guild_icon(id, guild_icon, size \\ nil) do
    "/icons/#{id}/#{guild_icon}"
    |> encode(guild_icon, size)
  end

  def guild_splash(id, splash, size \\ nil) do
    "/splashes/#{id}/#{splash}"
    |> encode(splash, size)
  end

  def guild_discovery_splash(guild_id, guild_discovery_splash, size \\ nil) do
    "discovery-splashes/#{guild_id}/#{guild_discovery_splash}"
    |> encode(guild_discovery_splash, size)
  end

  def guild_banner(guild_id, guild_banner, size \\ nil) do
    "banners/#{guild_id}/#{guild_banner}"
    |> encode(guild_banner, size)
  end

  def user_banner(user_id, user_banner, size \\ nil) do
    "banners/#{user_id}/#{user_banner}"
    |> encode(user_banner, size)
  end

  def default_user_avatar(user_dicriminator, size \\ nil) do
    "/embed/avatars/#{rem(user_dicriminator, 5)}"
    |> encode(user_dicriminator, size)
  end

  def user_avatar(id, user_avatar, size \\ nil) do
    "/avatars/#{id}/#{user_avatar}"
    |> encode(user_avatar, size)
  end

  def application_icon(application_id, icon, size \\ nil) do
    "app-icons/#{application_id}/#{icon}"
    |> encode(icon, size)
  end

  def appplication_cover(application_id, cover_image, size \\ nil) do
    "app-icons/#{application_id}/#{cover_image}"
    |> encode(cover_image, size)
  end

  def application_asset(application_id, asset_id, size \\ nil) do
    "app-assets/#{application_id}/#{asset_id}"
    |> encode(asset_id, size)
  end

  def achievement_icon(application_id, achievement_id, icon_hash, size \\ nil) do
    "app-assets/#{application_id}/achievements/#{achievement_id}/icons/#{icon_hash}"
    |> encode(icon_hash, size)
  end

  def sticker_pack_banner(sticker_pack_banner_asset_id, size \\ nil) do
    "app-assets/710982414301790216/store/#{sticker_pack_banner_asset_id}"
    |> encode(sticker_pack_banner_asset_id, size)
  end

  ######
  #### Private
  #####

  defp encode(term, hash, size) do
    (@cdn <> term)
    |> put_extension(hash)
    |> put_size(size)
    |> URI.encode()
  end

  defp put_size(term, nil), do: term

  defp put_size(term, size) when is_integer(size) when size in [16, 32, 64, 128, 256, 512, 1024, 2048, 096] do
    term <> "?size=#{to_string(size)}"
  end

  defp put_size(term, size) when is_integer(size) when size < 16, do: put_size(term, 16)
  defp put_size(term, size) when is_integer(size) when size < 32, do: put_size(term, 32)
  defp put_size(term, size) when is_integer(size) when size < 64, do: put_size(term, 64)
  defp put_size(term, size) when is_integer(size) when size < 128, do: put_size(term, 128)
  defp put_size(term, size) when is_integer(size) when size < 256, do: put_size(term, 256)
  defp put_size(term, size) when is_integer(size) when size < 512, do: put_size(term, 512)
  defp put_size(term, size) when is_integer(size) when size < 1024, do: put_size(term, 1024)
  defp put_size(term, size) when is_integer(size) when size < 2048, do: put_size(term, 2048)
  defp put_size(term, size) when is_integer(size) when size > 4096, do: put_size(term, 4096)

  defp put_extension(term, hash)
  defp put_extension(term, "a_" <> _hash), do: term <> ".gif"
  defp put_extension(term, _), do: term <> ".jpg"
end
