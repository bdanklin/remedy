defmodule Remedy.Schema.Webhook do
  @moduledoc """
  Webhook
  """
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "webhooks" do
    field :avatar, :string
    field :name, :string
    field :token, :string
    field :type, :integer
    field :url, :string
    belongs_to :application, App
    belongs_to :channel, Channel
    belongs_to :guild, Guild
    belongs_to :source_channel, Channel
    belongs_to :source_guild, Guild
    belongs_to :user, User
  end
end

defmodule Remedy.Schema.IncomingWebhook do
  @moduledoc """
  Incoming Webhook
  """
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "webhooks" do
    field :name, :string
    field :type, :integer
    field :token, :string
    field :avatar, :string
    belongs_to :channel, Channel
    belongs_to :guild, Guild
    belongs_to :user, User
  end
end

defmodule Remedy.Schema.ApplicationWebhook do
  @moduledoc """
  Application Webhook
  """
  use Remedy.Schema

  @primary_key {:id, Snowflake, autogenerate: false}
  schema "webhooks" do
    field :type, :integer
    field :name, :string
    field :avatar, :string
    belongs_to :application, App
  end
end
