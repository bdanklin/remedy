defmodule Remedy.Schema.Interaction do
  @moduledoc false
  use Remedy.Schema, :model
  @primary_key {:id, Snowflake, autogenerate: false}

  schema "interaction" do
    field :type, :integer
    embeds_one :data, InteractionData
    field :token, :string
    field :version, :integer
    belongs_to :channel, Channel
    embeds_one :member, Member
    belongs_to :user, User
    belongs_to :message, Message
    belongs_to :guild, Guild
    belongs_to :application, App
  end
end

defmodule Remedy.Schema.InteractionData do
  @moduledoc """
  This is the center point between Commands, Interactions and Components.

  Should probably be the center point of any command framework
  """
  use Remedy.Schema, :model
  @primary_key false

  embedded_schema do
    field :id, Snowflake
    field :name, :string
    field :type, :integer
    field :custom_id, :string
    field :component_type, :integer
    field :values, {:array, :string}
    field :target_id, Snowflake
    embeds_one :resolved, InteractionDataResolved
    embeds_many :options, InteractionDataOption
  end
end

defmodule Remedy.Schema.InteractionDataOption do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    field :name, :string
    field :type, :integer
    field :value, :string
    embeds_many :options, __MODULE__
  end
end

defmodule Remedy.Schema.InteractionDataResolved do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do
    embeds_many :users, User
    embeds_many :members, Members
    embeds_many :roles, Roles
    embeds_many :channels, Channels
    embeds_many :messages, Messages
  end

  # defp map_parse(nil, _target_type) do
  #   nil
  # end

  # defp map_parse(structure, target_type) do
  #   # Conversion of digit strings to integers is performed in `Util.safe_atom_map`.
  #   structure
  #   |> Enum.map(fn {k, v} -> {k, Util.cast(v, target_type)} end)
  #   |> :maps.from_list()
  # end

  # def to_struct(map) do
  #   %__MODULE__{
  #     users: map_parse(map[:users], {:struct, User}),
  #     members: map_parse(map[:members], {:struct, Member}),
  #     roles: map_parse(map[:roles], {:struct, Role}),
  #     channels: map_parse(map[:channels], {:struct, Channel}),
  #     messages: map_parse(map[:messages], {:struct, Message})
  #   }
  # end
end
