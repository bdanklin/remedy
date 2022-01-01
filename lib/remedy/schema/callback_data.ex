defmodule Remedy.Schema.CallbackData do
  use Remedy.Schema
  alias Remedy.Schema.CallbackDataFlags

  @type t :: %__MODULE__{
          tts: :boolean,
          content: String.t(),
          flags: CallbackDataFlags.t(),
          allowed_mentions: [AllowedMention.t()],
          embeds: [Embed.t()],
          attachments: [Attachment.t()],
          components: [Component.t()]
        }

  @primary_key false
  embedded_schema do
    field :tts, :boolean
    field :content, :string
    field :flags, CallbackDataFlags
    embeds_one :allowed_mentions, AllowedMentions
    embeds_many :embeds, Embed
    embeds_many :components, Component
    embeds_many :attachments, Attachment
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:tts, :content, :flags])
    |> cast_embed(:allowed_mentions)
    |> cast_embed(:embeds)
    |> cast_embed(:components)
    |> cast_embed(:attachments)
  end
end
