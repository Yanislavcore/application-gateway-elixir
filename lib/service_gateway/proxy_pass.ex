defmodule ServiceGateway.ProxyPass do
  @moduledoc false
  defstruct [:name, :route_info, :destinations, :timeout]

  @type t :: %__MODULE__{
               :name => String.t(),
               :route_info => [String.t()],
               :destinations => Destination.t(),
               :timeout => non_neg_integer()
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
      :failed_threshold
    ]
  end
end
