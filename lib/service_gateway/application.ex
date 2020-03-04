defmodule ServiceGateway.Application do
  @moduledoc false

  def rate_limiter_pool_name do
    :rate_limiter_pool
  end

  defp rate_limiter_pool_spec do
    pool_config = [
      name: {:local, rate_limiter_pool_name()},
      worker_module: ServiceGateway.RateLimiterWorker,
      size: System.schedulers_online(),
      strategy: :fifo
    ]
    :poolboy.child_spec(rate_limiter_pool_name(), pool_config, [])
  end

  defp cowboy_spec do
    port = Application.fetch_env!(ServiceGateway.Application, :port)
    {
      Plug.Cowboy,
      scheme: :http,
      plug: ServiceGateway.Plug,
      options: [
        port: port
      ]
    }
  end

  use Application

  def start(_type, _args) do

    children = [
      rate_limiter_pool_spec(),
      cowboy_spec()
    ]
    opts = [strategy: :one_for_one, name: ServiceGateway.Supervisor]
    Supervisor.start_link(children, opts)
  end
end