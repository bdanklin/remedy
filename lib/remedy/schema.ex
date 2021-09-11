defmodule Remedy.Schema do
  @moduledoc false

  defmacro __using__(_env) do
    quote do
      alias Remedy.Schema

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
        Role,
        StageInstance,
        Sticker,
        StickerPack,
        Team,
        TeamMember,
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

      def changeset(params), do: changeset(%__MODULE__{}, params)
      def changeset(nil, params), do: changeset(%__MODULE__{}, params)

      def changeset(%__MODULE__{} = model, params) do
        model
        |> cast(params, castable())
        |> cast_embeds()
      end

      defp cast_embeds(cast_model) do
        Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
      end

      defp castable do
        __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
      end

      def validate(changeset), do: changeset
      defoverridable validate: 1
    end
  end
end
