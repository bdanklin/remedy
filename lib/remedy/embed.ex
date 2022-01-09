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

  It is recommended
  """

  use Remedy.Schema, :schema_alias

  @doc """
  Update the Author to a user or member.
  """
  @spec put_author(Embed.t(), Member.c() | User.c()) :: Embed.t()
  def put_author(embed, %{nick: nickname, user: user} = member) do
    update(embed, author: %{icon_url: Member.avatar(member) || User.avatar(user), name: nickname})
  end

  @doc """
  Add the bot as the author.
  """
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
  Adds a field to the embed.
  """
  @spec put_field(Embed.t(), String.t(), String.t(), boolean() | nil) :: Embed.t()
  def put_field(%{fields: fields} = embed, name, value, inline \\ true) do
    update(embed, fields: fields ++ [%{name: name, value: value, inline: inline}])
  end

  @doc """
  Update the embeds timestamp.
  """
  @spec put_timestamp(Embed.t(), ISO8601.c()) :: Embed.t()
  def put_timestamp(embed, timestamp) do
    update(embed, timestamp: timestamp)
  end

  defp update(embed, params) do
    params = Enum.into(params, %{})
    Embed.changeset(embed, params) |> Ecto.Changeset.apply_changes()
  end
end
