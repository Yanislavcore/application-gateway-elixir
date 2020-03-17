defmodule ServiceGateway.Application do
  @moduledoc false
  use Application
  alias ServiceGateway.Utils.ConfigLoader
  import ServiceGateway.Utils.Constants
  import Logger

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
    Logger.info("Starting app on #{port} port!")

    {
      Plug.Cowboy,
      scheme: :http,
      plug: ServiceGateway.Controller,
      options: [
        port: port
      ]
    }
  end

  def start(_type, _args) do
    ConfigLoader.load_config()

    children = [
      selector_pool_spec(),
      cowboy_spec()
    ]

    opts = [strategy: :one_for_one, name: ServiceGateway.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
