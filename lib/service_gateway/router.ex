defmodule ServiceGateway.Router do
  @moduledoc false
  @on_load :load_routes
  alias ServiceGateway.ProxyPass
  alias ServiceGateway.ProxyPass.Destination

  @doc """
  Prepares routes and loads them into application context.
  """
  @spec load_routes() :: none()
  def load_routes() do
    all_routes =
      for group <- Application.fetch_env!(ServiceGateway.Application, :routes),
          route <- group[:route] do
        destinations =
          group[:destinations]
          |> Enum.with_index(0)
          |> Enum.map(fn {dest, i} ->
            %Destination{
              id: group.name <> "-" <> to_string(i),
              url: dest.url,
              weight: dest.weight
            }
          end)

        %ProxyPass{
          name: group[:name],
          route_info: String.split(route, "/", trim: true),
          timeout: group[:timeout],
          destinations: destinations
        }
      end

    :ok = Application.put_env(ServiceGateway.Application, :routes_prepared, all_routes)
  end

  @doc """
  Searches for a suitable route in configuration.
  """
  @spec find_proxy_pass([String.t()]) :: {:ok, ProxyPass.t()} | {:error, :not_found}
  def find_proxy_pass(path_info) do
    res =
      Application.fetch_env!(ServiceGateway.Application, :routes_prepared)
      |> Enum.find(fn %{route_info: route_info} -> List.starts_with?(path_info, route_info) end)

    if res do
      {:ok, res}
    else
      {:error, :not_found}
    end
  end
end
