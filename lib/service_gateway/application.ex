defmodule ServiceGateway.Application do
  @moduledoc false
  use Application

  def rate_limit_cache_name do
    :rate_limit_cache
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

  defp rate_limit_cache_spec do
    # TODO
    %{cache_entries_limit: cache_entries_limit} =
      Application.fetch_env!(ServiceGateway.Application, :rate_limiting)

    [
      %{
        id: rate_limit_cache_name(),
        start: {Cachex, :start_link, [rate_limit_cache_name(), [limit: cache_entries_limit]]}
      }
    ]
  end

  def start(_type, _args) do
    children = [
      #      ,
      cowboy_spec()
    ]

    opts = [strategy: :one_for_one, name: ServiceGateway.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
