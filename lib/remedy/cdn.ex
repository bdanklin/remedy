defmodule Remedy.CDN do
  alias Remedy.Schema.{App, Guild, StickerPack, User}
  @cdn "https://cdn.discordapp.com"

  @moduledoc """
  Discord CDN interface.

  Storing images and other assets can be painful, use this module to retreive assets from the discord cdn rather than storing them.

  Each function takes the required parameters to directly access a resource.

  ## Format

  All images are returned as either a `.png` or a `.gif` if the asset is animated. This is done automatically.

  ## Size

  Images can be requested of a size in `[16, 32, 64, 128, 256, 512, 1024, 2048, 4096]`. This is given as an optional final argument to any of the functions in this module. Arguments given will be rounded to the next largest, or the largest size if you try to go over.

  ## Missing Endpoints:

  - sticker
  - team icon
  - role icon
  - guild member icon

  """

  @type size :: integer() | nil

  @type snowflake :: Snowflake.t()

  @type hash :: binary()

  @type discriminator :: integer()

  def custom_emoji(id, size \\ nil) do
    "/emojis/#{id}" |> encode(id, size)
  end

  @spec guild_icon(Guild.t(), size) :: binary
  def guild_icon(guild, size \\ nil)
  def guild_icon(%Guild{id: id, icon: icon}, size), do: guild_icon(id, icon, size)
  def guild_icon(%{id: id, icon: icon}, size), do: guild_icon(id, icon, size)

  @doc false
  # @spec guild_icon(snowflake, any, any) :: binary
  def guild_icon(id, guild_icon, size) do
    "/icons/#{id}/#{guild_icon}" |> encode(guild_icon, size)
  end

  @spec guild_splash(Guild.t(), size) :: binary
  def guild_splash(guild, size \\ nil)
  def guild_splash(%Guild{id: id, splash: splash}, size), do: guild_splash(id, splash, size)
  def guild_splash(%{id: id, splash: splash}, size), do: guild_splash(id, splash, size)

  @doc false
  # @spec guild_splash(snowflake, hash, size) :: binary
  def guild_splash(id, splash, size) do
    "/splashes/#{id}/#{splash}"
    |> encode(splash, size)
  end

  @spec guild_discovery_splash(Guild.t(), size) :: binary
  def guild_discovery_splash(guild, size \\ nil)

  def guild_discovery_splash(%Guild{id: id, discovery_splash: discovery_splash}, size),
    do: guild_discovery_splash(id, discovery_splash, size)

  @doc false
  #  @spec guild_discovery_splash(snowflake, hash, size) :: binary
  def guild_discovery_splash(guild_id, guild_discovery_splash, size) do
    "discovery-splashes/#{guild_id}/#{guild_discovery_splash}"
    |> encode(guild_discovery_splash, size)
  end

  @spec guild_banner(Guild.t(), size) :: binary
  def guild_banner(guild, size \\ nil)
  def guild_banner(%Guild{id: id, banner: banner}, size), do: guild_banner(id, banner, size)

  @doc false
  # @spec guild_banner(snowflake, hash, size) :: binary
  def guild_banner(guild_id, guild_banner, size) do
    "banners/#{guild_id}/#{guild_banner}"
    |> encode(guild_banner, size)
  end

  @spec user_banner(User.t(), size) :: binary
  def user_banner(user, size \\ nil)

  def user_banner(%User{id: id, banner: banner}, size),
    do: user_banner(id, banner, size)

  @doc false
  # @spec user_banner(snowflake, hash, size) :: binary
  def user_banner(user_id, user_banner, size) do
    "banners/#{user_id}/#{user_banner}"
    |> encode(user_banner, size)
  end

  @spec default_user_avatar(User.t(), size) :: binary
  def default_user_avatar(user, size \\ nil)

  def default_user_avatar(%User{discriminator: discriminator}, size),
    do: default_user_avatar(discriminator, size)

  @doc false
  #  @spec default_user_avatar(discriminator, size) :: binary
  def default_user_avatar(discriminator, size) do
    "/embed/avatars/#{rem(discriminator, 5)}"
    |> encode(discriminator, size)
  end

  @spec user_avatar(User.t(), size) :: binary
  def user_avatar(user, size \\ nil)

  def user_avatar(%User{avatar: nil, discriminator: discriminator}, size),
    do: default_user_avatar(discriminator, size)

  def user_avatar(%User{id: id, avatar: user_avatar}, size),
    do: user_avatar(id, user_avatar, size)

  @doc false
  # @spec user_avatar(snowflake, hash, size) :: binary
  def user_avatar(id, user_avatar, size) do
    "/avatars/#{id}/#{user_avatar}"
    |> encode(user_avatar, size)
  end

  @spec application_icon(App.t(), size) :: binary
  def application_icon(application, size \\ nil)
  def application_icon(%App{id: id, icon: icon}, size), do: application_icon(id, icon, size)

  @doc false
  # @spec application_icon(snowflake, hash, size) :: binary
  def application_icon(application_id, icon, size) do
    "app-icons/#{application_id}/#{icon}"
    |> encode(icon, size)
  end

  @spec application_cover(App.t(), size) :: binary
  def application_cover(application, size \\ nil)

  def application_cover(%App{id: application_id, cover_image: cover_image}, size),
    do: application_cover(application_id, cover_image, size)

  @doc false
  #  @spec application_cover(snowflake, hash, size) :: binary
  def application_cover(application_id, cover_image, size) do
    "app-icons/#{application_id}/#{cover_image}"
    |> encode(cover_image, size)
  end

  @doc false
  # @spec application_asset(snowflake, hash, size) :: binary
  def application_asset(application_id, asset_id, size \\ nil) do
    "app-assets/#{application_id}/#{asset_id}"
    |> encode(asset_id, size)
  end

  @doc false

  def achievement_icon(application_id, achievement_id, icon_hash, size \\ nil) do
    "app-assets/#{application_id}/achievements/#{achievement_id}/icons/#{icon_hash}"
    |> encode(icon_hash, size)
  end

  @spec sticker_pack_banner(Sticker.t(), size) :: binary
  def sticker_pack_banner(sticker_pack, size \\ nil)

  def sticker_pack_banner(%StickerPack{banner_asset_id: banner_asset_id}, size),
    do: sticker_pack_banner(banner_asset_id, size)

  @doc false
  def sticker_pack_banner(banner_asset_id, size) do
    "app-assets/710982414301790216/store/#{banner_asset_id}"
    |> encode(banner_asset_id, size)
  end

  ############
  #### Private
  ############

  defp encode(term, hash, size) do
    (@cdn <> term)
    |> put_extension(hash)
    |> put_size(size)
    |> URI.encode()
  end

  defp put_size(term, nil), do: term

  defp put_size(term, size)
       when is_integer(size)
       when size in [16, 32, 64, 128, 256, 512, 1024, 2048, 4096] do
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
