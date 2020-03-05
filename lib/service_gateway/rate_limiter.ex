defmodule ServiceGateway.RateLimiter do
  @moduledoc false
  import ServiceGateway.Application, only: [rate_limit_cache_name: 0]

  @spec try_token(ip: String.t()) :: boolean()
  def try_token(ip) do
    {:ok, result} = Cachex.execute()
    result
  end

  @spec windows_number() :: integer()
  defp windows_number,
    do: Application.fetch_env!(ServiceGateway.Application, :rate_limiting)[:windows]

  @spec window_length_millis() :: integer()
  defp window_length_millis,
    do: Application.fetch_env!(ServiceGateway.Application, :rate_limiting)[:window_length_millis]

  @spec limit() :: integer()
  defp limit,
    do: Application.fetch_env!(ServiceGateway.Application, :rate_limiting)[:limit]
end
