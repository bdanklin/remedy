defmodule Remedy.Cache do
  @moduledoc """
  Functions for interacting with the Cache.

  The Cache is implemented in ETS.

  ## Bang!

  While undocumented to reduce clutter, all functions can be banged to return or raise.
  """

  import Remedy.TimeHelpers, only: [is_snowflake: 1]
  import Ecto.Query, warn: false

  alias Remedy.Repo
  alias Remedy.Schema.{App, Ban, Channel, Emoji, Guild, Member, Role, User}
  use Unsafe.Generator, handler: :unwrap, docs: false

  @type snowflake :: Snowflake.t()
  @type reason :: String.t()
  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()

  @not_found :not_found

  @doc """
  Fetch a channel from the cache.

  """
  @unsafe {:fetch_channel, [:id]}
  @spec fetch_channel(snowflake) :: {:error, reason} | {:ok, Remedy.Schema.Channel.t()}
  def fetch_channel(id) when is_snowflake(id) do
    case Repo.get(Channel, id) do
      nil -> {:error, @not_found}
      %Channel{} = channel -> {:ok, channel}
    end
  end

  @doc """
  List channels from the cache.

  """
  @unsafe {:list_channels, [:guild_id]}
  @spec list_channels(snowflake) :: {:error, term} | {:ok, [Remedy.Schema.Channel.t()]}
  def list_channels(guild_id \\ nil)
  def list_channels(nil), do: Repo.all(Channel) |> wrap_list()

  def list_channels(guild_id) do
    Repo.all(where(Channel, guild_id: ^guild_id)) |> wrap_list()
  end

  @doc """
  Fetch a ban from the Cache by user_id & guild_id

  """

  @spec fetch_ban(snowflake, snowflake) :: {:error, reason} | {:ok, Ban.t()}
  @unsafe {:fetch_ban, [:guild_id, :user_id]}
  def fetch_ban(guild_id, user_id) do
    case get_ban(guild_id, user_id) do
      nil ->
        {:error, @not_found}

      %Ban{} = ban ->
        {:ok,
         ban
         |> Repo.preload(:guild)
         |> Repo.preload(:user)}
    end
  end

  @doc """
  Returns True/False to the user being banned from a guild.
  """
  @spec user_banned?(any, any) :: true | false
  def user_banned?(guild_id, user_id) do
    case get_ban(guild_id, user_id) do
      nil -> false
      %Ban{} -> true
    end
  end

  @doc """
  List all bans
  """
  @spec list_bans :: {:error, reason} | {:ok, [Ban.t()]}
  @unsafe {:list_bans, []}
  def list_bans, do: Repo.all(Ban) |> wrap_list()

  @doc """
  List all bans associated with a guild.
  """
  @spec list_guild_bans(snowflake) :: {:error, reason} | {:ok, [Ban.t()]}
  @unsafe {:list_guild_bans, [:guild_id]}
  def list_guild_bans(guild_id) do
    Repo.all(where(Ban, guild_id: ^guild_id)) |> wrap_list()
  end

  @doc """
  List all bans associated with a user.
  """
  @spec list_user_bans(snowflake) :: {:error, reason} | {:ok, [Ban.t()]}
  @unsafe {:list_user_bans, [:user_id]}
  def list_user_bans(user_id) do
    Repo.all(where(User, user_id: ^user_id)) |> wrap_list()
  end

  @spec get_ban(snowflake, snowflake) :: nil | Ban.t()
  def get_ban(guild_id, user_id), do: Repo.get_by(Ban, %{guild_id: guild_id, user_id: user_id})

  @doc """
  Fetch a user from the cache.

  Returns {:ok, %User{}} or {:error, reason}
  """
  @unsafe {:fetch_user, [:id]}
  def fetch_user(user_id) do
    User
    |> Repo.get(user_id)
    |> wrap()
  end

  @doc """
  List Members
  """
  def list_members do
    Member |> Repo.all()
  end

  def get_member(guild_id, user_id), do: Repo.get_by(Member, %{guild_id: guild_id, user_id: user_id})

  def update_member(%{guild_id: guild_id, user_id: user_id} = attrs) do
    case get_member(guild_id, user_id) do
      nil -> Member.changeset(attrs) |> Repo.insert()
      %Member{} = member -> member |> Member.changeset(attrs) |> Repo.update()
    end
  end

  def update_member(%{guild_id: _guild_id, user: %{id: user_id}} = attrs) do
    Map.put_new(attrs, :user_id, user_id) |> update_member()
  end

  @doc """
  Fetch a guild from the cache
  """
  @unsafe {:fetch_guild, [:id]}
  def fetch_guild(id) do
    case Repo.get(Guild, id) do
      nil -> {:error, @not_found}
      %Guild{} = guild -> {:ok, guild |> guild_preloaders() |> drop_unloaded_assoc() |> drop_metadata()}
    end
  end

  defp guild_preloaders(guild) do
    guild
    |> Repo.preload(:members)
    |> Repo.preload(:channels)
    |> Repo.preload(:emojis)
    |> Repo.preload(:presences)
    |> Repo.preload(:roles)
    |> Repo.preload(:stage_instances)
    |> Repo.preload(:stickers)
    |> Repo.preload(:threads)
    |> Repo.preload(:voice_states)
    |> Repo.preload(:bans)
  end

  def list_guilds do
    Repo.all(Guild)
  end

  @doc """
  Fetch a emoji from the cache
  """
  @unsafe {:fetch_emoji, [:id]}
  def fetch_emoji(id) do
    case Repo.get(Emoji, id) do
      nil -> {:error, @not_found}
      %Emoji{} = emoji -> {:ok, emoji}
    end
  end

  @doc """
  Fetch a role from the cache.

  Returns {:ok, %Role{}} or {:error, reason}
  """
  @unsafe {:fetch_role, [:role_id]}
  @spec fetch_role(any) :: {:error, :not_found} | {:ok, Role.t()}
  def fetch_role(role_id), do: Repo.get(Role, role_id) |> wrap()

  @doc false
  def init_bot(bot) do
    clear_bot_cache()

    User.system_changeset(bot)
    |> Repo.insert()
  end

  def bot, do: Repo.get_by(User, %{remedy_system: true})

  defp clear_bot_cache() do
    case bot() do
      %User{} = user -> Repo.delete(user)
      nil -> :noop
    end
  end

  @doc false
  def init_app(app) do
    clear_app_cache()

    App.system_changeset(app)
    |> Repo.insert()
  end

  def app, do: Repo.get_by(App, %{remedy_system: true})

  defp clear_app_cache do
    case app() do
      %App{} = app -> Repo.delete(app)
      nil -> :noop
    end
  end

  alias Ecto.Association.NotLoaded

  @spec drop_unloaded_assoc(map) :: any
  def drop_unloaded_assoc(%{} = map), do: drop_by(map, fn _, val -> val in [%NotLoaded{}] end)

  @spec drop_metadata(map) :: any
  def drop_metadata(%{} = map), do: drop_by(map, fn key, _ -> key in [:__meta__] end)

  defp drop_by(struct, _predicate) when is_struct(struct), do: struct
  defp drop_by(map, predicate) when is_map(map), do: clean_by(map, predicate)
  defp drop_by(list, predicate) when is_list(list), do: Enum.map(list, &drop_by(&1, predicate))
  defp drop_by(elem, _predicate), do: elem

  defp clean_by(map, predicate) do
    Enum.reduce(map, %{}, fn {key, val}, acc ->
      if predicate.(key, drop_by(val, predicate)) do
        acc
      else
        Map.put(acc, key, drop_by(val, predicate))
      end
    end)
  end

  defp wrap_list({:error, _reason} = error), do: error
  defp wrap_list([]), do: {:ok, []}
  defp wrap_list([_ | _] = list), do: {:ok, list}

  defp wrap(%{} = struct), do: {:ok, struct}
  defp wrap(nil), do: {:error, @not_found}

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise("Cache Error")
end
