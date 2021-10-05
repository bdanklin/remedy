defmodule Remedy.CDN do
  @cdn "https://cdn.discordapp.com"

  @moduledoc """
  Discord CDN interface.

  Storing images and other assets can be painful, use this module to retreive assets from the discord cdn rather than storing them.

  Each function takes the required parameters to directly access a resource.

  ## Format

  All images are returned as either a `.png` or a `.gif` if the asset is animated. This is done automatically.

  ## Size

  Images can be requested of a size in `[16, 32, 64, 128, 256, 512, 1024, 2048, 4096]`. This is given as an optional final argument to any of the functions in this module. Arguments given will be rounded to the next largest, or the largest size if you try to go over.

  Unless specified, discord will deliver the smallest size available. ( Potato )

  ## Missing Endpoints:

  - sticker
  - team icon
  - role icon
  - guild member icon

  """

  @typedoc """
  The images size.
  """
  @type size :: integer() | nil

  @typedoc """
  The snowflake id of the resource.
  """
  @type snowflake :: Snowflake.t()

  @typedoc """
  The images hash.
  """
  @type hash :: binary()

  @typedoc """
  A four digit integer assigned by discord to avoid duplicate usernames
  """
  @type discriminator :: integer()

  @doc """
  Returns the url for a custom emoji.

  """
  @spec custom_emoji(snowflake, size) :: binary
  def custom_emoji(id, size \\ nil) do
    "/emojis/#{id}" |> encode(id, size)
  end

  @doc """
  Returns the url for a guilds icon.

  ## Examples

      iex> Remedy.CDN.guild_icon(872417560094732328, "f817c5adaf96672c94a17de8e944f427", "cheese")
      "https://cdn.discordapp.com/icons/872417560094732328/f817c5adaf96672c94a17de8e944f427.png"


  """

  @spec guild_icon(snowflake, hash, size) :: binary
  def guild_icon(id, guild_icon, size) do
    "/icons/#{id}/#{guild_icon}" |> encode(guild_icon, size)
  end

  @doc """
  Returns the url for a guilds splash.

  ## Examples

      iex> Remedy.CDN.guild_splash(848619361782726696, "7ed6ea26b7a5e64f78ca5df202cf4d13")
      "https://cdn.discordapp.com/splashes/848619361782726696/7ed6ea26b7a5e64f78ca5df202cf4d13.png"

  """

  @spec guild_splash(snowflake, hash, size) :: binary
  def guild_splash(id, splash, size) do
    "/splashes/#{id}/#{splash}"
    |> encode(splash, size)
  end

  @doc """
  Returns the url for a guilds discovery splash.


  """
  @spec guild_discovery_splash(snowflake, hash, size) :: binary
  def guild_discovery_splash(guild_id, guild_discovery_splash, size) do
    "/discovery-splashes/#{guild_id}/#{guild_discovery_splash}"
    |> encode(guild_discovery_splash, size)
  end

  @doc """
  Returns the url for a guilds banner.


  """

  @spec guild_banner(snowflake, hash, size) :: binary
  def guild_banner(guild_id, guild_banner, size) do
    "/banners/#{guild_id}/#{guild_banner}"
    |> encode(guild_banner, size)
  end

  @doc """
  Returns the url for a users banner.

  ## Examples

      iex> Remedy.CDN.user_banner(179255727561375744, "e625e858e48602248a69bcfdfa886ab4")
      "https://cdn.discordapp.com/banners/179255727561375744/e625e858e48602248a69bcfdfa886ab4.png"


  """

  @spec user_banner(snowflake, hash, size) :: binary
  def user_banner(user_id, user_banner, size) do
    "/banners/#{user_id}/#{user_banner}"
    |> encode(user_banner, size)
  end

  @doc """
  Returns the url for the default avatar of a user.

  That is, their avatar if they do not have one set, based on their discriminator. It can also take just the discriminator if you wish to do so.


  ## Examples

      iex> Remedy.API.get_current_user!() |> Remedy.CDN.default_user_avatar()
      "https://cdn.discordapp.com/embed/avatars/4.png"

      iex> Remedy.CDN.default_user_avatar(3)
      "https://cdn.discordapp.com/embed/avatars/3.png"

  """

  @spec default_user_avatar(discriminator, size) :: binary
  def default_user_avatar(discriminator, size) do
    "/embed/avatars/#{rem(discriminator, 5)}"
    |> encode(discriminator, size)
  end

  @doc """
  Returns the url for the users avatar.

  ## Examples

      iex> Remedy.CDN.user_avatar(707047919332884520, "1df05ae0f21a24c377e9a1051c2b6035", 128)
      "https://cdn.discordapp.com/avatars/707047919332884520/1df05ae0f21a24c377e9a1051c2b6035.png?size=128"


  """
  @spec user_avatar(snowflake, hash, size) :: binary
  def user_avatar(id, user_avatar, size) do
    "/avatars/#{id}/#{user_avatar}"
    |> encode(user_avatar, size)
  end

  @doc """
  Returns the url for the applications icon.


  """

  @spec application_icon(snowflake, hash, size) :: binary
  def application_icon(application_id, icon, size) do
    "/app-icons/#{application_id}/#{icon}"
    |> encode(icon, size)
  end

  @doc """
  Returns an application cover url.


  """
  @spec application_cover(snowflake, hash, size) :: binary
  def application_cover(application_id, cover_image, size) do
    "/app-icons/#{application_id}/#{cover_image}"
    |> encode(cover_image, size)
  end

  @doc """
  Returns an application asset url.


  """
  @spec application_asset(snowflake, hash, size) :: binary
  def application_asset(application_id, asset_id, size \\ nil) do
    "/app-assets/#{application_id}/#{asset_id}"
    |> encode(asset_id, size)
  end

  @doc """
  Returns an achievement icon url.


  """

  @spec achievement_icon(snowflake, snowflake, hash, size) :: binary
  def achievement_icon(application_id, achievement_id, icon_hash, size \\ nil) do
    "/app-assets/#{application_id}/achievements/#{achievement_id}/icons/#{icon_hash}"
    |> encode(icon_hash, size)
  end

  @doc """
  Returns a sticker banner url.
  """
  def sticker_pack_banner(banner_asset_id, size) do
    "/app-assets/710982414301790216/store/#{banner_asset_id}"
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
  defp put_size(term, size) when not is_integer(size), do: put_size(term, nil)

  defp put_size(term, size) when size in [16, 32, 64, 128, 256, 512, 1024, 2048, 4096] do
    term <> "?size=#{to_string(size)}"
  end

  defp put_size(term, size) when is_integer(size) and size < 16, do: put_size(term, 16)
  defp put_size(term, size) when is_integer(size) and size < 32, do: put_size(term, 32)
  defp put_size(term, size) when is_integer(size) and size < 64, do: put_size(term, 64)
  defp put_size(term, size) when is_integer(size) and size < 128, do: put_size(term, 128)
  defp put_size(term, size) when is_integer(size) and size < 256, do: put_size(term, 256)
  defp put_size(term, size) when is_integer(size) and size < 512, do: put_size(term, 512)
  defp put_size(term, size) when is_integer(size) and size < 1024, do: put_size(term, 1024)
  defp put_size(term, size) when is_integer(size) and size < 2048, do: put_size(term, 2048)
  defp put_size(term, size) when is_integer(size) and size > 4096, do: put_size(term, 4096)

  defp put_extension(term, hash)
  defp put_extension(term, "a_" <> _hash), do: term <> ".gif"
  defp put_extension(term, _), do: term <> ".png"
end
