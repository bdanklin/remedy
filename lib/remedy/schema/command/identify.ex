defmodule Remedy.Schema.Identify do
  @moduledoc false
  use Remedy.Schema, :model

  embedded_schema do

field :token	string	authentication token	-
field :properties	object	connection properties	-
field :compress?	boolean	whether this connection supports compression of packets	false
field :large_threshold?	integer	value between 50 and 250, total number of members where the gateway will stop sending offline members in the guild member list	50
field :shard?
field :presence?	update presence object	presence structure for initial presence information	-
field :intents	integer	the Gateway Intents you wish to receive	-
  end
end

defmodule Remedy.Gateway.ConnectionProperties do
    @moduledoc false
    use Remedy.Schema, :model

    embedded_schema dolooks like you are giving it a {:ok, guild} and it just wants a guild
      $os	string	your operating system
$browser	string	your library name
$device	string	your library name
    end

end
