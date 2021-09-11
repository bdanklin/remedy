defmodule Remedy.Schema.MessageSticker do
  @moduledoc false
  use Remedy.Schema

  @primary_key false
  schema "message_stickers" do
    belongs_to :message, Message
    belongs_to :sticker, Sticker
  end
end
