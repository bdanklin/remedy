defmodule Remedy.Schema.InteractionCallbackData do
  use Remedy.Schema

  @primary_key false
  embedded_schema do
    field :tts, :boolean
    field :content, :string
    field :flags, :integer
    embeds_one :allowed_mentions, AllowedMentions
    embeds_many :embeds, Embed
    embeds_many :components, Component
    embeds_many :attachments, Attachment
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:tts, :content, :flags])
    |> validate_inclusion(:flags, [0, 64])
    |> cast_embed(:allowed_mentions)
    |> cast_embed(:embeds)
    |> cast_embed(:components)
    |> cast_embed(:attachments)
  end
end
