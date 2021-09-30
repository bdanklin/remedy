defmodule Remedy.Schema.Message do
  @moduledoc """
  Message Object
  """
  use Remedy.Schema

  @type id :: Snowflake.t()
  @type content :: String.t()
  @type edited_timestamp :: ISO8601.t()
  @type flags :: integer()
  @type mention_everyone :: boolean()
  @type nonce :: integer()
  @type pinned :: boolean()
  @type timestamp :: ISO8601.t()
  @type tts :: boolean()
  @type type :: integer()
  @type application :: App.t()
  @type author :: User.t()
  @type channel :: Channel.t()
  @type guild :: Guild.t()
  @type thread :: Channel.t()
  @type webhook :: Webhook.t()
  @type attachments :: [Attachments.t()]
  @type components :: [Component.t()]
  @type embeds :: [Embed.t()]
  @type mention_channels :: [Channel.t()]
  @type mention_roles :: [Role.t()]
  @type mentions :: [User.t()]
  @type reactions :: [Reaction.t()]
  @type sticker_items :: [Sticker.t()]
  @type message_reference :: Reference.t()
  @type referenced_message :: Message.t()
  @type activity :: Activity.t()
  @type interaction :: Interaction.t()
  @type member :: Member.t()

  @type t :: %__MODULE__{
          id: id,
          content: content,
          edited_timestamp: edited_timestamp,
          flags: flags,
          mention_everyone: mention_everyone,
          nonce: nonce,
          pinned: pinned,
          timestamp: timestamp,
          tts: tts,
          type: type,
          application: application,
          author: author,
          channel: channel,
          guild: guild,
          thread: thread,
          webhook: webhook,
          attachments: attachments,
          components: components,
          embeds: embeds,
          mention_channels: mention_channels,
          mention_roles: mention_roles,
          mentions: mentions,
          reactions: reactions,
          sticker_items: sticker_items,
          message_reference: message_reference,
          referenced_message: referenced_message,
          activity: activity,
          interaction: interaction,
          member: member
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "messages" do
    field :content, :string
    field :edited_timestamp, ISO8601
    field :flags, :integer
    field :mention_everyone, :boolean
    field :nonce, :integer
    field :pinned, :boolean
    field :timestamp, ISO8601
    field :tts, :boolean
    field :type, :integer
    belongs_to :application, App
    belongs_to :author, User, foreign_key: :author_id
    belongs_to :channel, Channel
    belongs_to :thread, Channel
    belongs_to :guild, Guild
    embeds_one :webhook, Webhook
    embeds_many :attachments, Attachments
    embeds_many :components, Component
    embeds_many :embeds, Embed
    embeds_many :mention_channels, Channel
    embeds_many :mention_roles, Role
    embeds_many :mentions, User
    embeds_many :reactions, Reaction
    embeds_many :sticker_items, Sticker
    embeds_one :message_reference, Reference
    embeds_one :referenced_message, Message
    embeds_one :activity, Activity
    embeds_one :interaction, Interaction
    embeds_one :member, Member
  end

  def new(params) do
    params
    |> changeset()
    |> validate()
    |> apply_changes()
  end

  def update(model, params) do
    model
    |> changeset(params)
    |> validate()
    |> apply_changes()
  end

  def validate(changeset), do: changeset

  def changeset(params), do: changeset(%__MODULE__{}, params)
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = model, params) do
    cast(model, params, castable())
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end

  def link(%__MODULE__{guild_id: guild_id, channel_id: channel_id, id: id}) do
    "https://discord.com/channels/#{guild_id}/#{channel_id}/#{id}"
  end
end
