defmodule Remedy.Schema do
  @moduledoc false
  defp schema_helpers do
    parent = __MODULE__

    quote do
      alias unquote(parent)
      import Sunbake.Snowflake, only: [is_snowflake: 1]
      alias Sunbake.{ISO8601, Snowflake}

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
    end
  end

  defp payload_helpers do
    quote do
      alias Remedy.Schema.WSState
      alias Remedy.Gateway.Payload
      alias Remedy.Gateway.Commands.{Heartbeat, Identify, Hello}
    end
  end

  defmacro __using__(:model) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      unquote(schema_helpers())
      @before_compile Remedy.Schema.Model

      def validate(changeset), do: changeset
      defoverridable validate: 1
    end
  end

  defmacro __using__(:payload) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      unquote(schema_helpers())
      unquote(payload_helpers())
      @before_compile Remedy.Schema.Payload

      def validate(changeset), do: changeset
      defoverridable validate: 1
    end
  end

  defmacro __using__(_) do
    quote do
      unquote(schema_helpers())
    end
  end
end

defmodule Remedy.Schema.Model do
  @moduledoc false
  defmacro __before_compile__(_env) do
    quote do
      alias __MODULE__

      def new(params) do
        params
        |> changeset()
        |> apply_changes()
      end

      def changeset(params), do: changeset(%__MODULE__{}, params)

      def changeset(nil, params), do: changeset(%__MODULE__{}, params)

      def changeset(%__MODULE__{} = model, params) do
        model
        |> cast(params, castable())
        |> cast_embeds()
        |> apply_changes()
        |> Morphix.atomorphiform!()
      end

      defp cast_embeds(cast_model) do
        Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
      end

      defp castable do
        __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
      end
    end
  end
end

defmodule Remedy.Schema.Payload do
  @moduledoc false
  defmacro __before_compile__(_env) do
    quote do
      alias __MODULE__

      defp new(params \\ %{}), do: changeset(params)

      def changeset(params), do: changeset(%__MODULE__{}, params)
      def changeset(nil, params), do: changeset(%__MODULE__{}, params)

      def changeset(%__MODULE__{} = model, params) do
        model
        |> cast(params, castable())
        |> validate()
        |> cast_embeds()
        |> apply_changes()
        |> Map.from_struct()
        |> Morphix.stringmorphiform!()
      end

      def build_payload(data),
        do: data |> new() |> Remedy.Gateway.Payload.build(command())

      def command do
        __MODULE__
        |> to_string()
        |> String.split(".")
        |> List.last()
        |> Recase.to_snake()
        |> String.upcase()
      end

      defp cast_embeds(cast_model) do
        Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
      end

      defp castable do
        __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
      end
    end
  end
end
