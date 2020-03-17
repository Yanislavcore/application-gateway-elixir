defmodule ServiceGateway.Utils.ConfigLoader do
  alias ServiceGateway.ProxyPass
  alias ServiceGateway.ProxyPass.Destination

  @doc """
  Prepares routes and loads them into application context.
  """
  @spec load_config() :: none()
  def load_config() do
    all_routes =
      for group <- Application.fetch_env!(:service_gateway, :routes),
          route <- group[:route] do
        destinations =
          group[:destinations]
          |> Enum.with_index(0)
          |> Enum.map(fn {dest, i} ->
            %Destination{
              id: group.name <> "-" <> to_string(i),
              url: dest.url,
              weight: dest.weight,
              healthcheck_url: Map.get(dest, :healthcheck_url, dest.url),
              healthcheck_interval: Map.get(dest, :healthcheck_interval, 5000),
              threshold_interval: Map.get(dest, :threshold_interval, 15000),
              healthy_threshold: Map.get(dest, :healthy_threshold, 1),
              failed_threshold: Map.get(dest, :failed_threshold, 1)
            }
          end)

        %ProxyPass{
          name: group[:name],
          route_info: String.split(route, "/", trim: true),
          timeout: group[:timeout],
          destinations: destinations
        }
      end

    :ok = Application.put_env(:service_gateway, :routes_prepared, all_routes)
  end
end