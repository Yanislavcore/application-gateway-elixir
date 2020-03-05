defmodule ServiceGateway.Router do
  @moduledoc false
  @on_load :load_routes

  @doc """
  Prepares routes and loads them into application context.
  """
  @spec load_routes() :: none()
  def load_routes() do
    all_routes =
      for group <- Application.fetch_env!(ServiceGateway.Application, :routes),
          route <- group[:route] do
        {String.split(route, "/", trim: true), group[:destinations]}
      end

    :ok = Application.put_env(ServiceGateway.Application, :routes_prepared, all_routes)
  end

  @doc """
  Searches for a suitable route in configuration.
  """
  @spec find_destination([String.t()]) ::
          {:ok, {[String.t()], [%{url: String.t(), weight: integer()}]}}
          | {:error, :not_found}
  def find_destination(path_info) do
    res =
      Application.fetch_env!(ServiceGateway.Application, :routes_prepared)
      |> Enum.find(fn {route_info, _} -> List.starts_with?(path_info, route_info) end)

    if res do
      {:ok, res}
    else
      {:error, :not_found}
    end
  end
end
