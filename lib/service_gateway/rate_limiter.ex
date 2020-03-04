defmodule ServiceGateway.RateLimiter do
  @moduledoc false
  import ServiceGateway.Application, only: [rate_limiter_pool_name: 0]

  def calculate_square(value, sleep) when is_integer(value) and is_integer(sleep) do
    {:ok, result} = :poolboy.transaction(rate_limiter_pool_name(), fn p -> GenServer.call(p, {value, sleep}) end)
    result
  end
end
