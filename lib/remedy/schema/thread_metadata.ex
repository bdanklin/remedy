defmodule Remedy.Schema.ThreadMetadata do
  @moduledoc """
  Thread Metadata Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          archived: boolean(),
          auto_archive_duration: integer(),
          archive_timestamp: ISO8601.t(),
          locked: boolean(),
          invitable: boolean()
        }

  @primary_key false
  embedded_schema do
    field :archived, :boolean
    field :auto_archive_duration, :integer
    field :archive_timestamp, ISO8601
    field :locked, :boolean
    field :invitable, :boolean
  end

  def changeset(model \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)

    cast(model, params, fields -- embeds)
  end
end
