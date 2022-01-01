defmodule Remedy.Schema.Callback do
  use Remedy.Schema

  @type t :: %__MODULE__{
          type: :integer,
          data: CallbackData.t()
        }

  @primary_key false
  embedded_schema do
    field :type, :integer
    embeds_one :data, CallbackData
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:type])
    |> validate_inclusion(:type, [1, 4, 5, 6, 7, 8])
    |> cast_embed(:data)
  end
end
