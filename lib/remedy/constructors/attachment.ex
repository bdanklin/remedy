defmodule Remedy.Attachment do
  @moduledoc """
  `Ecto.Type` implementation for Attachments

  This is an intermediate type that is used to represent attachments within Remedy. It assists with uploading attachments to messages.

  It allows you increased freedom when uploading attachments and images to your messages. Instead of only being able to use remote URLs, you can also upload local files, or directly input image data.

  ## Casting

  #### Remote URL

      https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png

  #### Local File

      /path/to/file.png

  #### Image Data

       "image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASsAAACoCAMAAACPKThEAAABKVBMVEX////qQzU0qFP7vARChfT7ugA5gfTpNiQnpEr80mjZ5vz4ycWf06vqQTPqPi88gvS70fr++vnpOSntQS4zqUxAnZ5Cg/rv9f4kpEn2+f798O///vn7vwDpOzczfvREh/Tylo/tYVbvdm373dvuamD+78r++/D++Ob97ez946L+9Nn7wh71s67/1XDNtyLDVW7w+fJKsWWiwfiGrvdPjfXl7v3e8OPI2vt2wYlXtnDsWU3wgnrznJb2vbn0qqTxiYH619T94Z783Ir82Hz7yULrTT/957D83pH7xTH8zlb96bj+8sz4xrn3vp73toX2qmL1oUf1mjHkxUTMm07FZ4DIeJDOk6rSrMLWzuRZk/W638Nuv4NarKKX0KVzuqeMyKqNs/hvoPay3LyRAaJUAAAG0UlEQVR4nO2ca1fbRhBAJRtbQJAESltMRG1DbCiv1oAQmEASHuGRPpM+bUqL+f8/opJluRKWtGNpOatdz/2WHOyze8/s7OxoZUlCEARBEARBECTAwquFBdZj4IOF+vHx8UrjzcnpazRGYFVRVVXTNENR1NXt16yHk2deK6rso2qK1th+xXpIueWFIgdxddUxuKJ54srVZah1jK0oRl25toxt1uPKI1GuHFtK4xvWI8sf0a5kWVNPWQ8td8S5ckKrznpseSPWlSNrFYvTEPGuZNlo4H4YJM="

  """
  use Remedy.Schema
  import Remedy.ResourceHelpers
  use Ecto.Type
  @primary_key false
  embedded_schema do
    field :id, :integer
    field :description, :string
    field :filename, :string
    field :ext, :string
    field :mime, :string
    field :data, :any, virtual: true
    field :url, :string
    field :path, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:description, :filename, :ext, :mime, :data, :url, :path])
  end

  @doc false
  @impl true
  @spec type :: :map
  def type, do: :map

  @doc false
  @impl true
  def cast(value)
  def cast(nil), do: {:ok, nil}
  def cast(%__MODULE__{} = value), do: {:ok, value}

  def cast(value) when is_binary(value) do
    new(value)
    |> case do
      %Ecto.Changeset{valid?: true} = value -> {:ok, Ecto.Changeset.apply_changes(value)}
      _ -> :error
    end
  end

  @doc false

  @impl true
  def dump(nil), do: {:ok, nil}
  def dump(value) when is_map(value), do: {:ok, value}
  def dump(_value), do: :error

  @doc false
  @impl true
  def load(value), do: {:ok, value}

  def new(path, description \\ "") do
    cond do
      is_path?(path) -> from_path(path)
      is_url?(path) -> from_url(path)
      is_imagedata?(path) -> from_imagedata(path)
      true -> {:error, "Expected a local PATH or URL, got #{inspect(path)}"}
    end
    |> case do
      {:error, _reason} = error -> error
      params -> params
    end
    |> put_params(description)
    |> changeset()
  end

  defp from_url(path), do: {:url, path, data_from_url(path)}
  defp from_path(path), do: {:path, path, data_from_path(path)}

  defp from_imagedata(<<"image/png;base64,", data::binary>>),
    do: {:mime, "image/png", Base.decode64!(data)}

  defp from_imagedata(<<"image/jpg;base64,", data::binary>>),
    do: {:mime, "image/jpg", Base.decode64!(data)}

  defp from_imagedata(<<"image/gif;base64,", data::binary>>),
    do: {:mime, "image/gif", Base.decode64!(data)}

  defp put_params({:error, _reason} = error, _description), do: error

  defp put_params({key, path, data}, description) do
    %{}
    |> Map.put_new(key, path)
    |> Map.put_new(:description, description)
    |> Map.put_new(:data, data)
    |> put_meta()
  end

  defp put_meta(params) do
    extension = extension_from_params(params) |> List.first()

    params
    |> Map.put_new(:filename, filename_from_params(params))
    |> Map.put_new(:extension, extension)
    |> Map.put_new_lazy(:mime, fn -> MIME.type(extension) end)
  end

  defp filename_from_params(%{path: path}), do: Path.basename(path)
  defp filename_from_params(%{url: url}), do: Path.basename(url)

  defp filename_from_params(%{mime: mime}) do
    DateTime.now!("Etc/UTC")
    |> to_string()
    |> String.replace_suffix("", mime)
    |> String.replace([" ", ":", ".", "-", "/"], "_")
  end

  defp extension_from_params(%{path: path}), do: MIME.extensions(path)
  defp extension_from_params(%{url: url}), do: MIME.extensions(url)
  defp extension_from_params(%{mime: mime}), do: MIME.extensions(mime)
end
