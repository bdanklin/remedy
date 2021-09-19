defmodule Remedy.Schema do
  @moduledoc """
  Remedy Schema Behaviour

  Provides some basic schema helpers and alias automatically for the internal schema.

  > Note: It is not recommended to use this behaviour within your application. Instead you can import or alias the particular schema directly. eg `alias Remedy.Schema.Guild`

  """

  defmacro __using__(_env) do
    parent = __MODULE__

    quote do
      alias unquote(parent)

      alias Remedy.Schema.{
        App,
        AuditLog,
        AuditLogChange,
        AuditLogEntry,
        AuditLogOption,
        Ban,
        Channel,
        Command,
        Component,
        Embed,
        Emoji,
        Guild,
        Interaction,
        InteractionData,
        InteractionDataOption,
        InteractionDataResolved,
        Member,
        Message,
        Overwrite,
        Presence,
        Role,
        StageInstance,
        Sticker,
        StickerPack,
        Team,
        TeamMember,
        Thread,
        UnavailableGuild,
        User,
        Voice,
        VoiceState,
        Webhook
      }

      use Ecto.Schema
      import Ecto.Changeset
      import Sunbake.Snowflake, only: [is_snowflake: 1]
      alias Sunbake.{ISO8601, Snowflake}

      @before_compile Schema
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      alias __MODULE__

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

      defoverridable(validate: 1, new: 1, changeset: 1, changeset: 2)
    end
  end
end
