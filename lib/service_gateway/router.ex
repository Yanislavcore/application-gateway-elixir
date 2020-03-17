defmodule ServiceGateway.Router do
  @moduledoc false

  @doc """
  Searches for a suitable route in configuration.
  """
  @spec find_proxy_pass([String.t()]) :: {:ok, ProxyPass.t()} | {:error, :not_found}
  def find_proxy_pass(path_info) do
    res =
      Application.fetch_env!(:service_gateway, :routes_prepared)
      |> Enum.find(fn %{route_info: route_info} -> List.starts_with?(path_info, route_info) end)

    if res do
      {:ok, res}
    else
      {:error, :not_found}
    end
  end
end
