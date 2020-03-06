defmodule ServiceGateway.ProxyPassClient do
  @moduledoc false
  alias ServiceGateway.ProxyPass
  alias ServiceGateway.ProxyPass.Destination
  import Plug.Conn

  @spec request_proxy_pass(Plug.Conn.t(), ProxyPass.t(), Destination.t()) :: Mojito.Response.t()
  def request_proxy_pass(conn, pass, dest) do
    req = build_request(conn, pass, dest)
    Mojito.request(req)
  end

  defp build_request(conn, pass, dest) do
    %Mojito.Request{
      url: build_url(conn, pass, dest),
      method: conn.method,
      headers: get_headers(conn),
      body: get_body(conn)
    }
  end

  defp get_headers(conn) do
    filtered = conn.req_headers |> Enum.filter(fn {name, _} -> String.downcase(name) != "content-length" end)
    [{"X-Forwarded-For", to_string(:inet_parse.ntoa(conn.remote_ip))} | filtered]
  end

  defp build_url(conn, pass, dest) do
    base = if not String.ends_with?(dest.url, "/") do
      dest.url <> "/"
    else
      dest.url
    end
    suffix = Enum.drop(conn.path_info, length(pass.route_info))
             |> Enum.join("/")
    base <> suffix
  end

  defp headless?(method) do
    method == "GET" or method == "DELETE" or method == "HEAD"
  end

  defp get_body(conn, prefix \\ "") do
    if headless?(conn.method) do
      ""
    else
      case read_body(conn) do
        {:ok, end_part, _} -> prefix <> end_part
        {:more, part, conn} -> get_body(conn, prefix <> part)
      end
    end
  end
end
