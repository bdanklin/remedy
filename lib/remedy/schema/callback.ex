defmodule Remedy.Schema.Callback do
  @moduledoc """
  Callback Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: CallbackType.t(),
          data: CallbackData.t()
        }

  @primary_key false
  embedded_schema do
    field :type, CallbackType
    embeds_one :data, CallbackData
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:type])
    |> cast_embed(:data)
  end
end
