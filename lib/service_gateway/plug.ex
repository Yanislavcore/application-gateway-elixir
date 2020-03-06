defmodule ServiceGateway.Plug do
  @moduledoc false

  import Plug.Conn
  import Logger
  alias ServiceGateway.Router
  alias ServiceGateway.Selector
  alias ServiceGateway.ProxyPassClient

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    case Router.find_proxy_pass(conn.path_info) do
      {:ok, pass} -> call_proxy_pass(conn, pass)
      {:error, :not_found} ->
        Logger.warn("Calling for not existed route.")
        response_error(conn, 404, "Not found")
    end
  end

  defp call_proxy_pass(conn, pass) do
    case Selector.select_destination(pass) do
      {:ok, dest} ->
        resp = ProxyPassClient.request_proxy_pass(conn, pass, dest)
        case resp do
          {:ok, resp} -> send_proxy_response(conn, resp)
          {:error, %Mojito.Error{reason: :timeout}} ->
            Logger.warn("Error during call. Proxy pass timeout.")
            response_error(conn, 504, "Gateway Timeout")
          {:error, err} ->
            Logger.error("Error during call #{err.reason}.")
            response_error(conn, 500, "Internal Server Error")
        end
      {:error, _} -> response_error(conn, 503, "Service Unavailable")
    end
  end

  defp send_proxy_response(conn, resp) do
    conn
    |> prepend_resp_headers(resp.headers)
    |> send_resp(resp.status_code, resp.body)
  end

  defp response_error(conn, code, message) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(code, message)
  end
end
