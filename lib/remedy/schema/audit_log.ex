defmodule Remedy.Schema.AuditLog do
  @moduledoc """
  Discord Audit Log Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          guild: Guild.t(),
          webhooks: [Webhook.t()],
          users: [User.t()],
          audit_log_entries: [AuditLogEntry.t()],
          integrations: [Integration.t()],
          threads: [Thread.t()]
        }

  @primary_key false
  embedded_schema do
    belongs_to :guild, Guild
    embeds_many :webhooks, Webhook
    embeds_many :users, User
    embeds_many :audit_log_entries, AuditLogEntry
    embeds_many :integrations, Integration
    embeds_many :threads, Channel
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
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end

defmodule Remedy.Schema.AuditLogEntry do
  @moduledoc """
  Discord Audit Log Entry Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          target_id: String.t(),
          action_type: integer(),
          reason: String.t(),
          user: User.t(),
          options: [AuditLogOption.t()],
          changes: [AuditLogChange.t()]
        }

  @primary_key {:id, Snowflake, autogenerate: false}
  embedded_schema do
    field :target_id, :string
    field :action_type, :integer
    field :reason, :string
    belongs_to :user, User
    embeds_many :options, AuditLogOption
    embeds_many :changes, Change
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
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end

defmodule Remedy.Schema.AuditLogOption do
  @moduledoc """
  Discord Audit Log Option Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          delete_member_days: String.t(),
          members_removed: String.t(),
          channel: Channel.t(),
          message_id: Snowflake.t(),
          count: String.t(),
          id: Snowflake,
          overwrite: PermissionOverwrite.t(),
          type: String.t(),
          role_name: String.t()
        }

  @primary_key false
  embedded_schema do
    field :delete_member_days, :string
    field :members_removed, :string
    belongs_to :channel, Channel
    field :message_id, Snowflake
    field :count, :string
    field :id, Snowflake
    embeds_one :overwrite, PermissionOverwrite
    field :type, :string
    field :role_name, :string
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
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end

defmodule Remedy.Schema.AuditLogChange do
  @moduledoc """
  Discord Audit Log Change Object
  """
  use Remedy.Schema

  @type t :: %__MODULE__{
          new_value: term(),
          old_value: term(),
          key: term()
        }

  @primary_key false
  embedded_schema do
    field :new_value, :any, virtual: true
    field :old_value, :any, virtual: true
    field :key, :any, virtual: true
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
    cast(model, params, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embeds()
  end

  defp cast_embeds(cast_model) do
    Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
  end

  defp castable do
    __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
  end
end
