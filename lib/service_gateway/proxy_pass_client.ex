defmodule ServiceGateway.ProxyPassClient do
  @moduledoc false
  alias ServiceGateway.ProxyPass
  alias ServiceGateway.ProxyPass.Destination
  import Plug.Conn
  require Logger

  @spec request_proxy_pass(Plug.Conn.t(), ProxyPass.t(), Destination.t()) ::
          {:ok, Mojito.Response.t()} | {:error, %Mojito.Error{}}
  def request_proxy_pass(conn, pass, dest) do
    req = build_request(conn, pass, dest)
    Logger.debug("Request to proxy pass: " <> inspect(req, pretty: false))
    resp = Mojito.request(req)
    Logger.debug("Response from proxy pass: " <> inspect(resp, pretty: false))
    resp
  end

  defp build_request(conn, pass, dest) do
    %Mojito.Request{
      url: build_url(conn, pass, dest),
      method: conn.method,
      headers: get_headers(conn),
      body: get_body(conn),
      opts: Keyword.new([{:timeout, pass.timeout}])
    }
  end

  defp get_headers(conn) do
    filtered =
      conn.req_headers
      |> Enum.filter(fn {name, _} -> String.downcase(name) != "content-length" end)

    [{"X-Forwarded-For", to_string(:inet_parse.ntoa(conn.remote_ip))} | filtered]
  end

  defp build_url(conn, pass, dest) do
    base =
      if not String.ends_with?(dest.url, "/") do
        dest.url <> "/"
      else
        dest.url
      end

    suffix =
      Enum.drop(conn.path_info, length(pass.route_info))
      |> Enum.join("/")

    query_part =
      if conn.query_string == "" do
        ""
      else
        "?" <> conn.query_string
      end

    base <> suffix <> query_part
  end

  defp headless?(method) do
    method == "GET" or method == "DELETE" or method == "HEAD"
  end

  defp get_body(conn) do
    if headless?(conn.method) do
      ""
    else
      get_body_loop(conn, "")
    end
  end

  defp get_body_loop(conn, prefix) do
    case read_body(conn) do
      {:ok, end_part, _} -> prefix <> end_part
      {:more, part, conn} -> get_body_loop(conn, prefix <> part)
    end
  end
end
