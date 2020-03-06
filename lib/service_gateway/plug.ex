defmodule ServiceGateway.Plug do
  @moduledoc false

  import Plug.Conn
  alias ServiceGateway.Router

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    case Router.find_proxy_pass(conn.path_info) do
      {:ok, pass} -> call_proxy_pass(conn, pass)
      {:error, :not_foung} -> response_error(conn, 404, "Not found")
    end
  end

  defp call_proxy_pass(conn, pass) do
  end

  defp response_error(conn, code, message) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(code, message)
  end
end
