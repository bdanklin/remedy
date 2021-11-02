defmodule Remedy.Schema.Message do
  @moduledoc """
  Message Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          id: Snowflake.t(),
          content: String.t(),
          edited_timestamp: ISO8601.t(),
          flags: integer(),
          mention_everyone: boolean(),
          nonce: String.t(),
          pinned: boolean(),
          timestamp: ISO8601.t(),
          tts: boolean(),
          type: integer(),
          application: App.t(),
          author: User.t(),
          channel: Channel.t(),
          guild: Guild.t(),
          thread: Thread.t(),
          webhook: Webhook.t(),
          attachments: [Attachment.t()],
          components: [Component.t()],
          embeds: [Embed.t()],
          mention_channels: [Channel.t()],
          mention_roles: [Role.t()],
          mentions: [User.t()],
          reactions: [Reaction.t()],
          sticker_items: [Sticker.t()],
          message_reference: Reference.t(),
          referenced_message: Message.t(),
          activity: Activity.t(),
          interaction: Interaction.t(),
          member: Member.t()
        }

  @primary_key {:id, :id, autogenerate: false}
  schema "messages" do
    field :timestamp, ISO8601
    field :edited_timestamp, ISO8601

    field :flags, :integer
    field :mention_everyone, :boolean
    field :nonce, :integer
    field :pinned, :boolean
    field :tts, :boolean
    field :type, :integer

    belongs_to :application, App
    belongs_to :author, User, foreign_key: :author_id
    belongs_to :channel, Channel
    belongs_to :thread, Channel
    belongs_to :guild, Guild
    embeds_one :webhook, Webhook

    field :content, :string
    embeds_many :attachments, Attachment
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

    timestamps()
  end

  @doc false
  def form(params), do: params |> changeset() |> apply_changes()
  @doc false
  def shape(model, params), do: model |> changeset(params) |> apply_changes()
  @doc false

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, cast_model ->
      cast_embed(cast_model, embed)
    end)
  end

  def link(%__MODULE__{guild_id: guild_id, channel_id: channel_id, id: id}) do
    "https://discord.com/channels/#{guild_id}/#{channel_id}/#{id}"
  end
end
