defmodule ServiceGateway.Application do
  @moduledoc false
  use Application
  import ServiceGateway.Utils.Constants

  defp selector_pool_spec do
    pool_config = [
      name: {:local, selector_pool_name()},
      worker_module: ServiceGateway.SelectorWorker,
      size: System.schedulers_online(),
      strategy: :fifo
    ]

    workers_config = Application.fetch_env!(:service_gateway, :routes_prepared)
    :poolboy.child_spec(selector_pool_name(), pool_config, workers_config)
  end

  defp cowboy_spec do
    port = Application.fetch_env!(:service_gateway, :port)

    {
      Plug.Cowboy,
      scheme: :http,
      plug: ServiceGateway.Controller,
      options: [
        port: port
      ]
    }
  end

  #  defp rate_limit_cache_spec do
  #    # TODO
  #    %{cache_entries_limit: cache_entries_limit} =
  #      Application.fetch_env!(ServiceGateway.Application, :rate_limiting)
  #
  #    [
  #      %{
  #        id: rate_limit_cache_name(),
  #        start: {Cachex, :start_link, [rate_limit_cache_name(), [limit: cache_entries_limit]]}
  #      }
  #    ]
  #  end

  def start(_type, _args) do
    children = [
      selector_pool_spec(),
      cowboy_spec()
    ]

    opts = [strategy: :one_for_one, name: ServiceGateway.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
