defmodule Remedy.Schema do
  @moduledoc false
  defmacro __using__(:model) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      unquote(schema_helpers())
      @before_compile
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      alias __MODULE__

      def new(params) do
        params
        |> changeset()
        |> apply_changes()
      end

      def changeset(params), do: changeset(%__MODULE__{id: params.id}, params)

      def changeset(nil, params), do: changeset(%__MODULE__{id: params.id}, params)

      # seems very out of scope?
      def changeset(__MODULE__, params) do
        __MODULE__
        |> Cache.get(params.id)
        |> changeset(params)
      end

      def changeset(%__MODULE__{}, params) do
        model
        |> cast(params, castable())
        |> validations()
        |> cast_embeds()
      end

      def validations(model), do: model

      defp cast_embeds(cast_model) do
        Enum.reduce(__MODULE__.__schema__(:embeds), cast_model, &cast_embed(&1, &2))
      end

      defp castable do
        __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
      end

      defoverridable(changeset: 1, changeset: 2, validations: 1)
    end
  end

  defmacro __using__(_) do
    quote do
      unquote(schema_helpers())
    end
  end

  defp schema_helpers do
    parent = __MODULE__

    quote do
      alias unquote(parent)
      alias Sunbake.{Snowflake, ISO8601}
      import Sunbake.Snowflake, only: [is_snowflake: 1]

      alias Remedy.Schema.{
        App,
        AuditLog,
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
        Role,
        StageInstance,
        StickerPack,
        Sticker,
        TeamMember,
        Team,
        User,
        Voice,
        Webhook
      }
    end
  end
end
