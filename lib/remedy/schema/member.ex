defmodule Remedy.Schema.Member do
  @moduledoc """
  Guild Member Object
  """

  use Remedy.Schema

  @type t :: %__MODULE__{
          id: :id,
          nick: String.t(),
          joined_at: ISO8601.t(),
          premium_since: ISO8601.t(),
          deaf: boolean(),
          mute: boolean(),
          pending: boolean(),
          permissions: String.t(),
          roles: [Role.t()],
          user: User.t(),
          guild: Guild.t()
        }

  # Primary key :guild_id ++ :user_id
  @primary_key {:id, :id, autogenerate: false}
  schema "members" do
    field :nick, :string
    field :joined_at, ISO8601
    field :premium_since, ISO8601
    field :deaf, :boolean
    field :mute, :boolean
    field :pending, :boolean, default: false
    field :permissions, :string
    field :roles, {:array, :integer}
    belongs_to :user, User
    belongs_to :guild, Guild

    timestamps()
  end

  @to_cast ~w(id nick joined_at premium_since deaf mute pending permissions roles user_id guild_id)a
  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    params = put_pkey(params)

    model
    |> cast(params, @to_cast)
    |> validate_required([:guild_id, :user_id])
  end

  def put_pkey(%{user_id: user_id, guild_id: guild_id} = params) do
    id = "#{guild_id}#{user_id}" |> Integer.parse() |> elem(0)

    params
    |> Map.put_new(:id, id)
  end

  # def mention(%__MODULE__{user: user}), do: User.mention(user)
  #
  # @spec guild_channel_permissions(t, Guild.t(), Channel.id()) :: [Permission.t()]
  # def guild_channel_permissions(%__MODULE__{} = member, guild, channel_id) do
  #   use Bitwise

  #   guild_perms = guild_permissions(member, guild)

  #   if Enum.member?(guild_perms, :administrator) do
  #     Permission.all()
  #   else
  #     channel = Map.get(guild.channels, channel_id)

  #     everyone_role_id = guild.id
  #     role_ids = [everyone_role_id | member.roles]
  #     overwrite_ids = role_ids ++ [member.user.id]

  #     {allow, deny} =
  #       channel.permission_overwrites
  #       |> Enum.filter(&(&1.id in overwrite_ids))
  #       |> Enum.map(fn overwrite -> {overwrite.allow, overwrite.deny} end)
  #       |> Enum.reduce({0, 0}, fn {allow, deny}, {allow_acc, deny_acc} ->
  #         {allow_acc ||| allow, deny_acc ||| deny}
  #       end)

  #     allow_perms = allow |> Permission.from_bitset()
  #     deny_perms = deny |> Permission.from_bitset()

  #     guild_perms
  #     |> Enum.reject(&(&1 in deny_perms))
  #     |> Enum.concat(allow_perms)
  #     |> Enum.dedup()
  #   end
  # end

  # @doc """
  # Returns a member's guild permissions.

  # ## Examples

  # ```Elixir
  # guild = Remedy.Cache.GuildCache.get!(279093381723062272)
  # member = Map.get(guild.members, 177888205536886784)
  # Remedy.Struct.Guild.Member.guild_permissions(member, guild)
  # #=> [:administrator]
  # ```
  # """

  # # @spec guild_permissions(t, Guild.t()) :: [Permission.t()]
  # def guild_permissions(member, guild)

  # def guild_permissions(%__MODULE__{user: %{id: user_id}}, %Guild{owner_id: owner_id})
  #     when user_id === owner_id,
  #     do: Permission.all()

  # def guild_permissions(%__MODULE__{} = member, %Guild{} = guild) do
  #   use Bitwise

  #   everyone_role_id = guild.id
  #   member_role_ids = member.roles ++ [everyone_role_id]

  #   member_permissions =
  #     member_role_ids
  #     |> Enum.map(&Map.get(guild.roles, &1))
  #     |> Enum.filter(&(!match?(nil, &1)))
  #     |> Enum.reduce(0, fn role, bitset_acc ->
  #       bitset_acc ||| role.permissions
  #     end)
  #     |> Permission.from_bitset()

  #   if Enum.member?(member_permissions, :administrator) do
  #     Permission.all()
  #   else
  #     member_permissions
  #   end
  # end

  # @doc """
  # Return the topmost role of the given member on the given guild.

  # The topmost role is determined via `t:Remedy.Struct.Guild.Role.position`.

  # ## Parameters

  # - `member`: The member whose top role to return.
  # - `guild`: The guild which the member belongs to.

  # ## Return value

  # The topmost role of the member on the given guild, if the member has roles
  # assigned. Otherwise, `nil` is returned.
  # """
  # @doc since: "0.5.0"
  # # @spec top_role(__MODULE__.t(), Guild.t()) :: Role.t() | nil
  # def top_role(%__MODULE__{roles: member_roles}, %Guild{roles: guild_roles}) do
  #   guild_roles
  #   |> Stream.filter(fn {id, _role} -> id in member_roles end)
  #   |> Stream.map(fn {_id, role} -> role end)
  #   |> Enum.max_by(& &1.position, fn -> nil end)
  # end
end
