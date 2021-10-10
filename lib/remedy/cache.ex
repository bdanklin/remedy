defmodule Remedy.Cache do
  @moduledoc """
  Functions for interracting with the cache.
  """
  import Sunbake.Snowflake
  import Ecto.Query, warn: false
  alias Remedy.Cache.{Repo, DiscordBot, DiscordApp}
  alias Remedy.Schema.{App, Ban, Channel, Emoji, Guild, Member, Message, Presence, Role, Sticker, User}
  use Unsafe.Generator, handler: :unwrap, docs: true

  ############
  ### External
  ############

  @type snowflake :: Snowflake.t()
  @type reason :: String.t()
  @type attrs :: map()
  @doc """
  Fetch a channel from the cache.

  Returns {:ok, %Channel{}} or {:error, reason}
  """
  @unsafe {:fetch_channel, [:id]}
  def fetch_channel(id) when is_snowflake(id) do
    case Repo.get(Channel, id) do
      nil -> {:error, "Not Found"}
      %Ban{} = ban -> {:ok, ban}
    end
  end

  @doc false
  @spec create_channel(attrs) :: Channel.t()
  def create_channel(channel) do
    %Channel{}
    |> Channel.changeset(channel)
    |> Repo.insert!()
  end

  @doc false
  @spec update_channel(snowflake, attrs) :: Channel.t()
  def update_channel(id, channel) do
    Channel
    |> Repo.get(id)
    |> Channel.changeset(channel)
    |> Repo.update!()
  end

  @doc false
  @spec delete_channel(snowflake) :: Channel.t()
  def delete_channel(id) do
    Channel
    |> Repo.get(id)
    |> Repo.delete!()
  end

  @doc """
  Fetch a ban from the Cache by user_id & guild_id

  Returns {:ok, `%Remedy.Schema.Ban{}`} or {:error, reason}
  """

  @spec fetch_ban(snowflake, snowflake) :: {:error, reason} | {:ok, Ban.t()}
  @unsafe {:fetch_ban, [:user_id, :guild_id]}
  def fetch_ban(user_id, guild_id) do
    case get_ban(user_id, guild_id) do
      nil -> {:error, "Not Found"}
      %Ban{} = ban -> {:ok, ban}
    end
  end

  @doc """
  Fetch a use from the cache.

  Returns {:ok, %User{}} or {:error, reason}
  """
  @unsafe {:fetch_user, [:id]}
  def fetch_user(user_id) do
    User
    |> Repo.get(user_id)
  end

  @doc """
  Fetch a users presence information.

  Returns {:ok, %Presence{}, or {:error, reason}}
  """
  def fetch_presence(user_id) do
    case Repo.get(User, user_id).presence do
      nil -> {:error, "Not Found"}
      presence -> {:ok, presence}
    end
  end

  @doc false
  def update_presence(%{user: user} = presence) do
    upsert_user(user)
    |> User.changeset(%{presence: presence})
    |> Repo.update!()
  end

  ###########
  ### Opaque?
  ###########

  ## Bans

  @doc false
  def create_ban(%Ban{} = ban) do
    Repo.insert!(ban)
  end

  @doc false
  def delete_ban(user_id, guild_id) do
    get_ban(user_id, guild_id)
    |> Repo.delete()
  end

  @doc false
  def get_ban(user_id, guild_id) do
    Repo.get_by(Ban, %{guild_id: guild_id, user_id: user_id})
  end

  def create_guild(guild) do
    guild
    |> IO.inspect(pretty: true)
    |> Guild.changeset()
    |> Repo.insert!()
  end

  def get_guild(id) do
    Guild
    |> Repo.get(id)
  end

  def update_guilds([_ | _] = guilds), do: for(g <- guilds, do: update_guild(g))

  def update_guild(%{id: id} = guild) do
    Guild
    |> Repo.get(id)
    |> Guild.changeset(guild)
    |> Repo.update!()
  end

  def delete_guild(%{id: id} = _guild) do
    Guild
    |> Repo.get(id)
    |> Repo.delete!()
  end

  def upsert_user(%{id: id} = attrs) do
    case Repo.get(User, id) do
      nil -> create_user(attrs)
      %User{} -> update_user(attrs)
    end
  end

  def upsert_message(%{id: id} = attrs) do
    case Repo.get(Message, id) do
      nil -> create_message(attrs)
      %User{} -> update_message(id, attrs)
    end
  end

  def update_message(id, attrs) do
    Message
    |> Repo.get(id)
    |> Message.changeset(attrs)
    |> Repo.update!()
  end

  def create_user(user) do
    user
    |> User.changeset()
    |> Repo.insert!()
  end

  def update_user(%{id: id} = user) do
    User
    |> Repo.get(id)
    |> User.changeset(user)
    |> Repo.update!()
  end

  def delete_user(%{id: id} = _user) do
    User
    |> Repo.get(id)
    |> Repo.delete!()
  end

  def create_member(member) do
    member
    |> Member.changeset()
    |> Repo.insert!()
  end

  def update_member(%{id: id} = member) do
    Member
    |> Repo.get(id)
    |> Member.changeset(member)
    |> Repo.update!()
  end

  def delete_member(%{id: id} = _member) do
    Member
    |> Repo.get(id)
    |> Repo.delete!()
  end

  def create_message(message) do
    message
    |> Message.changeset()
    |> Repo.insert!()
  end

  def delete_message(%{id: id} = _message) do
    Message
    |> Repo.get(id)
    |> Repo.delete!()
  end

  def remove_message_reactions(message_id) do
    Message
    |> Repo.get(message_id)
    |> Message.changeset(%{reactions: []})
    |> Repo.update!()
  end

  @doc false
  def create_role(guild_id, role) do
    %Guild{id: guild_id}
    |> Ecto.build_assoc(:role)
    |> Role.changeset(role)
    |> Repo.insert!()
  end

  @doc """
  Set the initial condition of the bot.
  """
  def initialize_bot(app) do
    User.new(app)
    |> DiscordBot.update()
  end

  def update_bot(updated_state) do
    updated_state = Map.from_struct(updated_state)

    case bot() do
      nil ->
        User.new(updated_state)
        |> DiscordBot.update()

        bot()

      %User{} = old_bot_state ->
        User.update(old_bot_state, updated_state)
        |> DiscordBot.update()

        bot()
    end
  end

  def bot do
    DiscordBot.get()
  end

  def initialize_app(app) do
    App.new(app)
    |> DiscordApp.update()
  end

  def update_app(updated_app) do
    case app() do
      nil ->
        App.new(updated_app)
        |> DiscordApp.update()

        bot()

      %App{} = old_app_state ->
        App.update(old_app_state, updated_app)
        |> DiscordApp.update()

        bot()
    end
  end

  def app do
    DiscordApp.get()
  end

  defp unwrap({:ok, body}), do: body
  defp unwrap({:error, _}), do: raise(Remedy.APIError)
end

###############
### Supervisor
###############

defmodule Remedy.CacheSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    children = [
      Cache.App,
      Cache.Bot,
      Cache.Repo
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
