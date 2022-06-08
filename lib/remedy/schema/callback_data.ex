defmodule Remedy.Schema.CallbackData do
  @moduledoc """
  Callback Data Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          tts: :boolean,
          content: String.t(),
          flags: CallbackDataFlags.t(),
          allowed_mentions: AllowedMentions.t(),
          embeds: [Embed.t()],
          attachments: [Attachment.t()],
          components: [Component.t()]
        }

  @primary_key false
  embedded_schema do
    ## Auto Complete
    field :choices, {:array, :string}
    ## Modal
    field :custom_id, :string
    field :title, :string
    ## Message / Shared
    field :tts, :boolean
    field :content, :string
    field :flags, CallbackDataFlags
    embeds_one :allowed_mentions, AllowedMentions
    embeds_many :embeds, Embed
    embeds_many :components, Component
    embeds_many :attachments, Attachment
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params)

  ## Autocomplete
  def changeset(model, %{choices: _} = params) do
    model
    |> cast(params, [:choices])
    |> validate_required([:choices])
  end

  ## Modal
  def changeset(model, %{custom_id: _, title: _, components: _} = params) do
    model
    |> cast(params, [:custom_id, :title])
    |> validate_required([:custom_id, :title])
    |> cast_embed(:components)
  end

  ## Callback Message
  def changeset(model, params) do
    model
    |> cast(params, [:tts, :content, :flags])
    |> cast_embed(:allowed_mentions)
    |> cast_embed(:embeds)
    |> cast_embed(:components)
    |> cast_embed(:attachments)
  end
end
