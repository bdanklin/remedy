defmodule Remedy.Cache do
  @moduledoc """
  Functions for interracting with the cache.
  """
  import Sunbake.Snowflake
  import Ecto.Query, warn: false
  alias Remedy.Cache.{Repo, DiscordBot, DiscordApp}
  alias Remedy.Schema.{App, Ban, Channel, Emoji, Guild, Member, Message, Presence, Role, Sticker, User}
  use Unsafe.Generator, handler: :unwrap, docs: true

  @type snowflake :: Snowflake.t()
  @type reason :: String.t()
  ## Channels

  @doc """
  Fetch a channel from the cache.
  """
  @unsafe {:fetch_channel, [:id]}
  def fetch_channel(id) when is_snowflake(id) do
    Channel
    |> Repo.get(id)
  end

  @doc false
  def create_channel(%Channel{} = channel) do
    channel
    |> Repo.insert!()
  end

  @doc false
  def update_channel(id, channel) do
    Channel
    |> Repo.get(id)
    |> Channel.changeset(channel)
    |> Repo.update!()
  end

  @doc false
  def delete_channel(id) do
    Channel
    |> Repo.get(id)
    |> Repo.delete!()
  end

  ## Bans

  @doc """
  Fetch a ban from the Cache by user_id & guild_id

  Returns {:ok, `%Remedy.Schema.Ban{}`} or {:error, reason}
  """

  @spec fetch_ban(snowflake, snowflake) :: {:error, reason} | {:ok, Ban.t()}
  @unsafe {:fetch_ban, [:user_id, :guild_id]}
  def fetch_ban(user_id, guild_id) do
    case get_ban(user_id, guild_id) do
      nil -> {:error, "Not Found"}
      ban -> {:ok, ban}
    end
  end

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

  def update_message(%{id: id} = message) do
    Message
    |> Repo.get(id)
    |> Message.changeset(message)
    |> Repo.update!()
  end

  def update_message(id, updated_message) do
    Message
    |> Repo.get(id)
    |> Message.changeset(updated_message)
    |> Repo.update!()
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

  def create_emoji(emoji) do
    emoji
    |> Emoji.changeset()
    |> Repo.insert!()
  end

  def update_emoji(%{id: id} = emoji) do
    Emoji
    |> Repo.get(id)
    |> Emoji.changeset(emoji)
    |> Repo.update!()
  end

  def delete_emoji(%{id: id} = _emoji) do
    Emoji
    |> Repo.get(id)
    |> Repo.delete!()
  end

  def create_presence(presence) do
    presence
    |> Presence.changeset()
    |> Repo.insert!()
  end

  def update_presence(%{id: id} = presence) do
    Presence
    |> Repo.get(id)
    |> Presence.changeset(presence)
    |> Repo.update!()
  end

  def delete_presence(%{id: id} = _presence) do
    Presence
    |> Repo.get(id)
    |> Repo.delete!()
  end

  def create_role(role) do
    role
    |> Role.changeset()
    |> Repo.insert!()
  end

  def update_role(%{id: id} = role) do
    Role
    |> Repo.get(id)
    |> Role.changeset(role)
    |> Repo.update!()
  end

  def delete_role(%{id: id} = _role) do
    Role
    |> Repo.get(id)
    |> Repo.delete!()
  end

  def create_sticker(sticker) do
    sticker
    |> Sticker.changeset()
    |> Repo.insert!()
  end

  def update_sticker(%{id: id} = sticker) do
    Sticker
    |> Repo.get(id)
    |> Sticker.changeset(sticker)
    |> Repo.update!()
  end

  def delete_sticker(%{id: id} = _sticker) do
    Sticker
    |> Repo.get(id)
    |> Repo.delete!()
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
