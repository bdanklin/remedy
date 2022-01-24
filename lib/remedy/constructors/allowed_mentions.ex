defmodule Remedy.AllowedMentions do
  @moduledoc """
  Functions to assist with creating `AllowedMentions` objects.

  Even with the helpers in this module it is possible to produce invalid results.
  """
  alias Remedy.Schema.AllowedMentions

  def suppress_all(allowed_mentions \\ %AllowedMentions{}) do
    %AllowedMentions{allowed_mentions | parse: [], users: [], roles: []}
    |> validate()
  end

  def mention_all(allowed_mentions \\ %AllowedMentions{}) do
    %AllowedMentions{allowed_mentions | parse: ["users", "roles", "everyone"], users: [], roles: []}
    |> validate()
  end

  def mention_reply(allowed_mentions \\ %AllowedMentions{}) do
    %AllowedMentions{allowed_mentions | replied_user: true}
    |> validate()
  end

  def suppress_reply(allowed_mentions \\ %AllowedMentions{}) do
    %AllowedMentions{allowed_mentions | replied_user: false}
    |> validate()
  end

  def validate(model \\ %AllowedMentions{}, params) do
    params = mapify(params)
    cs = AllowedMentions.changeset(model, params)

    case cs.valid? do
      true ->
        Ecto.Changeset.apply_changes(cs)

      false ->
        raise "Invalid AllowedMentions"
    end
  end

  defp mapify(%AllowedMentions{} = a_m), do: Map.from_struct(a_m)
  defp mapify(a_m) when is_map(a_m), do: a_m

  def strip(model) do
    model
    |> Map.from_struct()
    |> Morphix.compactiform!()
  end
end
