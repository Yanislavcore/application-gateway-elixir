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
            :weight => pos_integer(),
            :healthcheck_url => String.t(),
            :healthcheck_interval => non_neg_integer(),
            :threshold_interval => non_neg_integer(),
            :healthy_threshold => pos_integer(),
            :timeout => non_neg_integer(),
            :failed_threshold => pos_integer()
          }
    defstruct [
      :id,
      :url,
      :weight,
      :healthcheck_url,
      :healthcheck_interval,
      :threshold_interval,
      :healthy_threshold,
      :timeout,
      :failed_threshold
    ]
  end
end
