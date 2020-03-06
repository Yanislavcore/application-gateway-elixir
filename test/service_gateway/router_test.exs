defmodule ServiceGateway.RouterTest do
  @moduledoc false
  use ExUnit.Case, async: false
  import ServiceGateway.Router

  ExUnit.Case.register_attribute(__ENV__, :triple)

  @parameters [
    {
      "/test/foo/",
      "/test/foo/",
      [
        %{
          name: "test1",
          route: ["/test/foo/"],
          destinations: [%{url: "https://postman-echo.com/get", weight: 1}]
        }
      ]
    },
    {
      "/test/foo/",
      "/test/",
      [
        %{
          name: "test2",
          route: ["/test/"],
          destinations: []
        }
      ]
    },
    {
      "/test/foo/bar/bar/foo",
      "/test",
      [
        %{
          name: "test3.1",
          route: ["/random"],
          destinations: []
        },
        %{
          name: "test3.2",
          route: ["/bar", "/test", "/test/foo/"],
          destinations: [%{url: "https://postman-echo.com/get", weight: 1}]
        },
        %{
          name: "test3.3",
          route: ["/barrrr"],
          destinations: []
        }
      ]
    }
  ]
  for {uri, expected, config} <- @parameters do
    @triple {uri, expected, config}
    test "Router should find '#{expected}' for '#{uri}'", context do
      {uri, expected, config} = context.registered.triple
      expected_split = String.split(expected, "/", trim: true)
      uri_split = String.split(uri, "/", trim: true)
      Application.put_env(ServiceGateway.Application, :routes, config)
      load_routes()
      assert {:ok, %{route_info: ^expected_split}} = find_proxy_pass(uri_split)
    end
  end
end
