defmodule ServiceGateway.ProxyPassClientTest do
  @moduledoc false
  use ExUnit.Case, async: true

  import FakeServer
  alias ServiceGateway.ProxyPassClient, as: C
  alias ServiceGateway.ProxyPass, as: PP
  alias ServiceGateway.ProxyPass.Destination, as: D

  def setup_test_with_server(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  test_with_server "should send all headers plus X-Forwarded-For with right IP" do
    test_route = "/config_pref/should/be/routed/here"

    route(test_route, fn r ->
      Agent.update(__MODULE__, fn l -> [r | l] end)
      FakeServer.Response.ok!("stubbed")
    end)

    result =
      C.request_proxy_pass(
        conn_base,
        %PP{
          name: "foo_bar_proxy_pass",
          route_info: ["prefix"],
          destinations: [],
          timeout: 5000
        },
        %D{
          id: "foo_bar_proxy_pass-0",
          url: "http://#{FakeServer.address()}/config_pref",
          weight: 1
        }
      )

    {:ok, resp} = result
    [endpoint_request] = Agent.get(__MODULE__, fn res -> res end)
    IO.inspect(endpoint_request)
    assert FakeServer.hits(test_route) == 1
    assert FakeServer.hits() == 1
    assert %Mojito.Response{status_code: 200, body: "stubbed"} = resp
    assert endpoint_request.body == nil

    assert Enum.filter(
             endpoint_request.headers,
             fn {k, v} ->
               !Enum.any?(conn_base.req_headers, fn {ek, ev} -> k == ek and v == ev end)
             end
           ) -- [conn_base.req_headers] == [
             {"content-length", "0"},
             {"x-forwarded-for", "20.20.20.1"}
           ]

    assert endpoint_request.query_string == conn_base.query_string
    assert endpoint_request.path == "/config_pref/should/be/routed/here"
  end

  defp conn_base do
    %Plug.Conn{
      method: "GET",
      path_info: ["prefix", "should", "be", "routed", "here"],
      path_params: %{},
      port: 8080,
      private: %{},
      query_string: "abc=234&pooo&mk=po",
      remote_ip: {20, 20, 20, 1},
      req_headers: [
        {"accept", "*/*"},
        {"accept-encoding", "gzip, deflate"},
        {"cache-control", "no-cache"},
        {"connection", "keep-alive"},
        {"content-length", "18"},
        {"content-type", "application/json"},
        {
          "cookie",
          "sails.sid=s%3Ats-D_XZP7lQ9Dvmvj0UQMCPul0orvrO-.2cjHUgcstp1jO%2F4DZHBFgJK6l8tJ0j%2Fh4UxHaoqbmHU"
        },
        {"host", "localhost:8080"},
        {"postman-token", "22fe29f6-4afb-483e-ba85-c83fd783b4de"},
        {"user-agent", "PostmanRuntime/7.21.0"}
      ],
      request_path: "/prefix/should/be/routed/here"
    }
  end
end
