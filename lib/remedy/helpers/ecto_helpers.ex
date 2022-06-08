defmodule Remedy.EctoHelpers do
  @moduledoc """
  This module contains helper functions for the Ecto module.
  """

  import Ecto.Changeset

  def validate_at_least(changeset, fields, at_least, opts \\ [])

  def validate_at_least(changeset, fields, at_least, opts)
      when is_list(fields) and is_integer(at_least) do
    present_keys = for field <- fields, into: [], do: get_field(changeset, field)

    validations =
      for field <- fields,
          into: [],
          do: {field, {:at_least, opts}}

    is_are = if at_least == 1, do: "is", else: "are"

    error_msg = String.trim_trailing("At least #{at_least} of: #{inspect(fields)} #{is_are} required.")

    field_presence =
      for field <- fields,
          into: %{},
          do: {to_string(field), to_string(field) in present_keys}

    errors =
      field_presence
      |> Enum.filter(fn {_k, v} -> v == true end)
      |> case do
        list_of_present_fields when length(list_of_present_fields) >= at_least ->
          []

        _ ->
          for {k, _v} <- field_presence,
              into: [],
              do: {String.to_existing_atom(k), {message(opts, error_msg), validation: :at_least}}
      end

    %{
      changeset
      | validations: validations ++ changeset.validations,
        errors: errors ++ changeset.errors,
        valid?: changeset.valid? and errors == []
    }
  end

  defp message(opts, key \\ :message, default) do
    Keyword.get(opts, key, default)
  end
end
