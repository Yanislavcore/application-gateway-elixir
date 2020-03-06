defmodule ServiceGateway.ProxyPass do
  @moduledoc false
  defstruct [:name, :route_info, :destinations]

  @type t :: %__MODULE__{
          :name => String.t(),
          :route_info => [String.t()],
          :destinations => Destination.t()
        }

  defmodule Destination do
    @type t :: %__MODULE__{
            :id => String.t(),
            :url => String.t(),
            :weight => pos_integer()
          }
    defstruct [:id, :url, :weight]
  end
end
