defmodule Remedy.Error.VoiceError do
  @moduledoc """
  Represents an error when playing sound through voice channels.

  This occurs when attempting to play audio and Porcelain can't find either
  the ffmpeg executable or the youtube-dl executable.
  """

  defexception [:message]

  def exception(reason: reason, executable: executable) do
    msg = "ERROR: #{reason} - #{executable} improperly configured"
    %__MODULE__{message: msg}
  end
end

defmodule Remedy.Error.CacheError do
  @moduledoc """
  Represents an error when interacting with the cache.

  This likely occurs because a specified item could not be found in the cache,
  or your were searching for something invalid.
  This should only occur when using the banged cache methods.
  """

  defexception [:message]

  def exception(finding: finding, cache_name: cache_name) do
    msg = "ERROR: No match for #{inspect(finding)} found in #{cache_name}"
    %__MODULE__{message: msg}
  end

  def exception(key: key, cache_name: cache_name) do
    msg = "ERROR: Key #{inspect(key)} not found in #{cache_name}"
    %__MODULE__{message: msg}
  end

  def exception(msg) do
    %__MODULE__{message: msg}
  end
end

defmodule Remedy.Error.ApiError do
  @moduledoc """
  Represents a failed response from the API.

  This occurs when hackney or HTTPoison fail, or when the API doesn't respond with `200` or `204`.
  This should only occur when using the banged API methods.

  Check the Format
  """

  defexception [
    :status_code,
    :response
  ]

  @type t :: %{
          status_code: status_code,
          response: response
        }

  @type status_code :: 100..511
  @type discord_status_code :: 10_001..90_001

  @type response :: String.t() | error | detailed_error

  @type detailed_error :: %{code: discord_status_code, message: String.t(), errors: errors}
  @type errors :: %{required(String.t()) => errors} | %{required(String.t()) => error_list_map}
  @type error_list_map :: %{_errors: [error]}
  @type error :: %{code: discord_status_code, message: String.t()}

  # TODO: pretty print for discord errors
  @impl true
  def message(%__MODULE__{
        response: %{code: error_code, message: message, errors: errors},
        status_code: code
      }) do
    "(HTTP #{code}) received Discord status code #{error_code} (#{message}) with errors: #{
      inspect(errors)
    }"
  end

  @impl true
  def message(%__MODULE__{response: %{code: error_code, message: message}, status_code: code}) do
    "(HTTP #{code}) received Discord status code #{error_code} (#{message})"
  end
end
