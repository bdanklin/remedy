defmodule Remedy.Cache do
  @moduledoc """
  Functions for interracting with the cache.

  The cache is populated only by events received from the gateway, it is not updated from interractions with the REST api.


  """
  import Sunbake.Snowflake
  import Ecto.Query, warn: false

  alias Remedy.Cache.Repo
  alias Remedy.Schema.{App, Ban, Channel, Guild, Integration, Interaction, Invite, Member, Message, Role, User}
  alias Ecto.Changeset

  use Unsafe.Generator, handler: :unwrap, docs: true

  @type snowflake :: Snowflake.t()
  @type reason :: String.t()
  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()

  @not_found :not_found

  ###########
  ### Channel
  ###########

  @doc """
  Fetch a channel from the cache.

  """
  @unsafe {:fetch_channel, [:id]}
  @spec fetch_channel(snowflake) :: {:error, reason} | {:ok, Remedy.Schema.Channel.t()}
  def fetch_channel(id) when is_snowflake(id) do
    case get_channel(id) do
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
  def list_channels(guild_id), do: Repo.all(where(Channel, guild_id: ^guild_id)) |> wrap_list()

  ### Internal
  @doc false
  @spec get_channel(snowflake) :: nil | Channel.t()
  def get_channel(id), do: Repo.get(Channel, id)
  @doc false
  @spec delete_channel(snowflake) :: {:ok, Channel.t()} | {:error, Changeset.t()}
  def delete_channel(id), do: get_channel(id) |> Repo.delete()

  @doc false
  @spec update_channel(snowflake, attrs) :: {:ok, Channel.t()} | {:error, Changeset.t()}
  def update_channel(id, attrs) do
    case get_channel(id) do
      nil ->
        Channel.changeset(attrs) |> Repo.insert()

      %Channel{} = channel ->
        Channel.changeset(channel, attrs) |> Repo.update()
    end
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

  @doc false
  @spec delete_ban(snowflake, snowflake) :: {:ok, Ban.t()} | {:error, Changeset.t()}
  def delete_ban(guild_id, user_id), do: get_ban(guild_id, user_id) |> Repo.delete()

  @doc false
  @spec update_ban(snowflake, snowflake, attrs) :: {:ok, Ban.t()} | {:error, Changeset.t()}
  def update_ban(guild_id, user_id, attrs), do: get_ban(guild_id, user_id) |> Ban.changeset(attrs) |> Repo.update()

  ###########
  ### User
  ###########
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

  def update_user(attrs) do
    case get_user(attrs) do
      nil ->
        User.changeset(attrs)
        |> Repo.insert()

      %User{} = user ->
        User.changeset(user, attrs)
        |> Repo.update()
    end
  end

  @doc false
  def get_user(%{id: id}), do: Repo.get(User, id)
  def get_user(id), do: Repo.get(User, id)

  def delete_user(id) do
    User |> Repo.get(id) |> Repo.delete()
  end

  ###########
  ### Members
  ###########

  @doc """
  List Members
  """
  def list_members do
    Member |> Repo.all()
  end

  def get_member(guild_id, user_id), do: Repo.get_by(Member, %{guild_id: guild_id, user_id: user_id}) |> wrap()

  def update_member(%{guild_id: g, user_id: u} = attrs), do: get_member(g, u) |> do_update_member(attrs)

  defp do_update_member({:error, :not_found}, attrs), do: Member.changeset(attrs) |> Repo.insert()
  defp do_update_member({:ok, member}, attrs), do: Member.changeset(member, attrs) |> Repo.update()

  @doc false
  def update_presence(%{user: user} = presence), do: Map.put_new(user, :presence, presence) |> update_user()

  @doc """
  Fetch a guild from the cache
  """
  @unsafe {:fetch_guild, [:id]}
  def fetch_guild(id) do
    case get_guild(id) do
      nil -> {:error, @not_found}
      %Guild{} = guild -> {:ok, guild |> Repo.preload([:members])}
    end
  end

  def list_guilds do
    Repo.all(Guild)
  end

  def update_guild_emojis(guild_id, params) do
    get_guild(guild_id)
    |> Repo.preload(:emojis)
    |> Guild.update_emojis_changeset(params)
    |> Repo.update()
  end

  def update_guild_stickers(guild_id, params) do
    get_guild(guild_id)
    |> Repo.preload(:stickers)
    |> Guild.update_stickers_changeset(params)
    |> Repo.update()
  end

  @doc false
  @spec update_guild(attrs) :: any
  def update_guild(%{id: id} = attrs) do
    case get_guild(id) do
      nil -> Guild.changeset(attrs) |> Repo.insert()
      %Guild{} = guild -> Guild.changeset(guild, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec get_guild(snowflake) :: nil | Guild.t()
  def get_guild(guild_id), do: Repo.get(Guild, guild_id)

  @doc false
  @spec delete_guild(snowflake) :: {:ok, Guild.t()} | {:error, Changeset.t()}
  def delete_guild(guild_id), do: get_guild(guild_id) |> Repo.delete()

  @doc """
  Fetch an integration by ID.

  """
  def fetch_integration(integration_id) do
    integration_id
    |> get_integration()
    |> wrap()
  end

  @doc false
  @spec get_integration(snowflake) :: nil | Integration.t()
  def get_integration(integration_id), do: Repo.get(Integration, integration_id)

  @doc false
  @spec delete_integration(snowflake) :: {:ok, Integration.t()} | {:error, Changeset.t()}
  def delete_integration(integration_id), do: get_integration(integration_id) |> Repo.delete()

  @doc false
  @spec update_integration(snowflake, attrs) :: {:ok, Integration.t()} | {:error, Changeset.t()}
  def update_integration(integration_id, attrs) do
    case get_integration(integration_id) do
      nil -> Integration.changeset(attrs) |> Repo.insert()
      %Integration{} = integration -> Integration.changeset(integration, attrs) |> Repo.update()
    end
  end

  #################
  #### Interactions
  #################

  def create_interaction(attrs) do
    attrs
    |> Interaction.changeset()
    |> Repo.insert()
  end

  ############
  #### Invites
  ############

  @doc false
  @spec get_invite(snowflake) :: nil | Invite.t()
  def get_invite(invite_id), do: Repo.get(Invite, invite_id)

  @doc false
  @spec delete_invite(snowflake) :: {:ok, Invite.t()} | {:error, Changeset.t()}
  def delete_invite(invite_id), do: get_invite(invite_id) |> Repo.delete()

  #############
  #### Message
  #############

  @doc false
  def update_message(%{id: id} = attrs) do
    case Repo.get(Message, id) do
      nil -> Message.changeset(attrs) |> Repo.insert()
      %Message{} = message -> Message.changeset(message, attrs) |> Repo.update()
    end
  end

  @doc false
  @spec get_message(snowflake) :: nil | Message.t()
  def get_message(message_id), do: Repo.get(Message, message_id)

  @doc false
  @spec delete_message(snowflake) :: {:ok, Message.t()} | {:error, Changeset.t()}
  def delete_message(message_id), do: get_message(message_id) |> Repo.delete()

  @doc false
  @spec update_message(snowflake, attrs) :: {:ok, Message.t()} | {:error, Changeset.t()}
  def update_message(message_id, attrs),
    do: get_message(message_id) |> Message.changeset(attrs) |> Repo.update()

  @spec remove_message_reactions(snowflake) :: {:ok, Message.t()} | {:error, reason}
  def remove_message_reactions(message_id) do
    get_message(message_id) |> Message.changeset(%{reactions: []}) |> Repo.update()
  end

  #########
  ### Roles
  #########

  @doc """
  Fetch a role from the cache.

  Returns {:ok, %Role{}} or {:error, reason}
  """
  @unsafe {:fetch_role, [:role_id]}
  @spec fetch_role(any) :: {:error, :not_found} | {:ok, Role.t()}
  def fetch_role(role_id), do: get_role(role_id) |> wrap()

  @doc false
  @spec create_role(attrs) :: any
  def create_role(attrs), do: Role.changeset(attrs) |> Repo.insert()

  @doc false
  @spec get_role(snowflake) :: nil | Role.t()
  def get_role(id), do: Repo.get(Role, id)

  @doc false
  @spec delete_role(snowflake) :: {:ok, Role.t()} | {:error, Changeset.t()}
  def delete_role(id), do: get_role(id) |> Repo.delete()

  @doc false
  @unsafe {:update_role, [:id, :attrs]}
  @spec update_role(snowflake, attrs) :: {:ok, Role.t()} | {:error, Changeset.t()}
  def update_role(id, attrs) do
    case get_role(id) do
      nil -> Role.changeset(attrs) |> Repo.insert()
      %Role{} = role -> Role.changeset(role, attrs) |> Repo.update()
    end
  end

  @doc false
  def init_bot(bot), do: User.system_changeset(bot) |> Repo.insert()

  def bot, do: Repo.get_by(User, %{remedy_system: true})

  @doc false
  def init_app(app), do: App.system_changeset(app) |> Repo.insert()

  def app, do: Repo.get_by(App, %{remedy_system: true})

  defp wrap_list({:error, _reason} = error), do: error
  defp wrap_list([]), do: {:ok, []}
  defp wrap_list([_ | _] = list), do: {:ok, list}

  defp wrap(%{} = struct), do: {:ok, struct}
  defp wrap(nil), do: {:error, @not_found}

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise("Cache Error")
end
