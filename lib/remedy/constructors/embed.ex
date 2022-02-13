defmodule Remedy.Embed do
  @moduledoc """
  Convenience functions for working with embeds.

  Using the helpers in this module you can coneniently convert various objects into fields within an embed, allowing easier manipulation and more consistent embeds with less boilerplate.

  Consider you wish to create an embed regarding an action that a user took. We can use pre established objects to populate the embed fields. For example:

      user = %User{id: 1, name: "John Doe"}
      message = %Message{text: "Hello World", timestamp: timestamp}

      %Embed{}
      |> put_author(user)
      |> put_timestamp(timestamp)
      |> put_colour("#F34AC3")
      |> put_title("User Silenced")
      |> put_description("User was silenced for breaking the rules.")

  """

  use Remedy.Schema, :schema_alias

  @doc """
  Update the Author to a user or member.
  """
  @spec put_author(Embed.t(), Member.t()) :: Embed.t()
  def put_author(embed, %Member{nick: nickname} = member) do
    update(embed, author: %{icon_url: Member.avatar(member), name: nickname})
  end

  @spec put_author(Embed.t(), User.t()) :: Embed.t()
  def put_author(embed, %User{username: nickname} = user) do
    update(embed, author: %{icon_url: User.avatar(user), name: nickname})
  end

  @doc """
  Add the bot as the author.
  """
  # Todo: Get from cache
  @spec put_author(Embed.t()) :: Embed.t()
  def put_author(embed) do
    update(embed, author: %{name: "Remedy", icon_url: "https://cdn.discordapp.com/embed/avatars/0.png"})
  end

  @doc """
  Update the embed colour.
  """
  @spec put_colour(Embed.t(), Colour.c()) :: Embed.t()
  def put_colour(embed, color) do
    update(embed, color: color)
  end

  @doc """
  Update the embed description.
  """
  @spec put_description(Embed.t(), String.t()) :: Embed.t()
  def put_description(embed, description) do
    update(embed, description: description)
  end

  @doc """
  append a field to the embed.
  """
  def append_field(%{fields: fields} = embed, name, value, inline \\ true) do
    with %EmbedField{} = new_field <- update(%{}, %{name: name, value: value, inline: inline}, EmbedField) do
      update(embed, fields: fields ++ [new_field])
    else
      {:error, _reason} -> embed
    end
  end

  @doc """
  append a field to the embed.
  """
  def prepend_field(%{fields: fields} = embed, name, value, inline \\ true) do
    new_field = update(%{}, %{name: name, value: value, inline: inline}, EmbedField)

    update(embed, fields: [new_field] ++ fields)
  end

  @doc """
  Update the embeds timestamp.
  """
  def put_timestamp(embed, timestamp) do
    update(embed, timestamp: timestamp)
  end

  defp update(model, params, schema \\ Embed) do
    params = Enum.into(params, %{})
    cs = schema.changeset(model, params)

    case cs.valid? do
      true -> Ecto.Changeset.apply_changes(cs)
      false -> {:error, cs.errors}
    end
  end
end
