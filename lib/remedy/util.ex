defmodule Remedy.Util do
  @moduledoc """
  Utility functions
  """

  alias Remedy.{Api, Constants, Snowflake}
  alias Remedy.Schema.WSState
  alias Remedy.Shard.Session

  require Logger

  @doc """
  Helper for defining all the methods used for struct and encoding transformations.

  ## Example
  ``` Elixir
  Remedy.Util.remedy_struct(%{
    author: User,
    mentions: [User],
    mention_roles: [User],
    embeds: [Embed]
  })
  ```
  """
  defmacro remedy_struct(body) do
    quote do
      @derive [Poison.Encoder]
      defstruct Map.keys(unquote(body))

      def p_encode do
        encoded =
          for {k, v} <- unquote(body), v != nil, into: %{} do
            case v do
              [v] -> {k, [v.p_encode]}
              v -> {k, v.p_encode}
            end
          end

        struct(__ENV__.module, encoded)
      end

      def to_struct(map) do
        alias Remedy.Util

        new_map =
          for {k, v} <- unquote(body), into: %{} do
            case v do
              nil -> {k, Map.get(map, k)}
              [v] -> {k, Util.enum_to_struct(Map.get(map, k), v)}
              v -> {k, apply(v, :to_struct, [Map.get(map, k)])}
            end
          end

        struct(__ENV__.module, new_map)
      end
    end
  end

  @doc """
  Returns the number of milliseconds since unix epoch.
  """
  @spec now() :: integer
  def now do
    DateTime.utc_now()
    |> DateTime.to_unix(:millisecond)
  end

  @doc """
  Returns the number of microseconds since unix epoch.
  """
  @spec usec_now() :: integer
  def usec_now do
    DateTime.utc_now()
    |> DateTime.to_unix(:microsecond)
  end

  @doc """
  Returns the current date as an ISO formatted string.
  """
  @spec now_iso() :: String.t()
  def now_iso do
    DateTime.utc_now()
    |> DateTime.to_iso8601()
  end

  @doc false
  def list_to_struct_list(list, struct) when is_list(list) do
    Enum.map(list, &struct.to_struct(&1))
  end

  def enum_to_struct(nil, _struct), do: nil
  def enum_to_struct(enum, struct) when is_list(enum), do: Enum.map(enum, &struct.to_struct(&1))

  def enum_to_struct(enum, struct) when is_map(enum) do
    for {k, v} <- enum, into: %{} do
      {k, struct.to_struct(v)}
    end
  end

  @doc """
  Returns the number of shards.

  This is not the number of currently active shards, but the number of shards specified
  in your config.
  """
  @spec num_shards() :: integer
  def num_shards do
    num =
      with :auto <- Application.get_env(:remedy, :num_shards, :auto),
           {_url, shards} <- Remedy.Shard.Supervisor.gateway(),
           do: shards

    if num == nil, do: 1, else: num
  end

  @doc false
  def bangify_find(to_bang, find, cache_name) do
    case to_bang do
      {:ok, res} ->
        res

      {:error} ->
        raise(Remedy.CacheError, finding: find, cache_name: cache_name)

      {:error, _other} ->
        raise(Remedy.CacheError, finding: find, cache_name: cache_name)
    end
  end

  @doc """
  Converts a map into an atom-keyed map.

  Given a map with variable type keys, returns the same map with all keys as `atoms`.
  To support maps keyed with integers (such as in Discord's interaction data),
  binaries that appear to be integers will be parsed as such.

  This function will attempt to convert keys to an existing atom, and if that fails will default to
  creating a new atom while displaying a warning. The idea here is that we should be able to see
  if any results from Discord are giving variable keys. Since we *will* define all
  types of objects returned by Discord, the amount of new atoms created *SHOULD* be 0. 👀
  """
  @spec safe_atom_map(map) :: map
  def safe_atom_map(term) do
    cond do
      is_map(term) ->
        for {key, value} <- term, into: %{}, do: {maybe_to_atom(key), safe_atom_map(value)}

      is_list(term) ->
        Enum.map(term, fn item -> safe_atom_map(item) end)

      true ->
        term
    end
  end

  @doc """
  Attempts to convert a string to an atom.

  Binary `token`s that consist of digits are assumed to be snowflakes, and will
  be parsed as such.

  If atom does not currently exist, will warn that we're doing an unsafe conversion.
  """
  @spec maybe_to_atom(atom | String.t()) :: atom | integer
  def maybe_to_atom(token) when is_atom(token), do: token

  def maybe_to_atom(<<head, _rest::binary>> = token) when head in ?1..?9 do
    case Integer.parse(token) do
      {snowflake, ""} ->
        snowflake

      _ ->
        :erlang.binary_to_atom(token)
    end
  end

  def maybe_to_atom(token) do
    String.to_existing_atom(token)
  rescue
    _ ->
      Logger.debug(fn -> "Converting string to non-existing atom: #{token}" end)
      String.to_atom(token)
  end

  # Generic casting function
  @doc false
  @spec cast(term, module | {:list, term} | {:struct, term} | {:index, [term], term}) :: term
  def cast(value, type)
  def cast(nil, _type), do: nil

  def cast(values, {:list, type}) when is_list(values) do
    Enum.map(values, fn value ->
      cast(value, type)
    end)
  end

  # Handles the case where the given term is already indexed
  def cast(values, {:index, _index_by, _type}) when is_map(values), do: values

  def cast(values, {:index, index_by, type}) when is_list(values) do
    values
    |> Enum.into(%{}, &{&1 |> get_in(index_by) |> cast(Snowflake), cast(&1, type)})
  end

  def cast(value, {:struct, module}) when is_map(value) do
    module.to_struct(value)
  end

  def cast(value, module) do
    case module.cast(value) do
      {:ok, result} -> result
      _ -> value
    end
  end

  @doc """
  Since we're being sacrilegious and converting strings to atoms from the WS, there will be some
  atoms that we see that aren't defined in any Discord structs. This method mainly serves as a
  means to define those atoms once so the user isn't warned about them in the
  `Remedy.Util.maybe_to_atom/1` function when they are in fact harmless.
  """
  def unused_atoms do
    [
      :active,
      :audio,
      :audio_codec,
      :audio_ssrc,
      :channel_overrides,
      :convert_emoticons,
      :detect_platform_accounts,
      :developer_mode,
      :enable_tts_command,
      :encodings,
      :experiments,
      :friend_source_flags,
      :friend_sync,
      :guild_positions,
      :inline_attachment_media,
      :inline_embed_media,
      :last_message_id,
      :locale,
      :max_bitrate,
      :media_session_id,
      :message_display_compact,
      :message_notifications,
      :mobile_push,
      :modes,
      :muted,
      :recipients,
      :referenced_message,
      :render_embeds,
      :render_reactions,
      :require_colons,
      :restricted_guilds,
      :rid,
      :rtx_ssrc,
      :scale_resolution_down_by,
      :show_current_game,
      :suppress_everyone,
      :theme,
      :video,
      :video_codec,
      :video_ssrc,
      :visibility
    ]
  end
end
