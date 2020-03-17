defmodule ServiceGateway.RouterTest do
  @moduledoc false
  use ExUnit.Case, async: false
  import ServiceGateway.Router
  alias ServiceGateway.Utils.ConfigLoader

  ExUnit.Case.register_attribute(__ENV__, :triple)

  @parameters [
    {
      "/test/foo/",
      "/test/foo/",
      [
        %{
          name: "test1",
          route: ["/test/foo/"],
          timeout: 1000,
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
          timeout: 1000,
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
          timeout: 1000,
          destinations: []
        },
        %{
          name: "test3.2",
          route: ["/bar", "/test", "/test/foo/"],
          timeout: 1000,
          destinations: [%{url: "https://postman-echo.com/get", weight: 1}]
        },
        %{
          name: "test3.3",
          route: ["/barrrr"],
          timeout: 1000,
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
      Application.put_env(:service_gateway, :routes, config)
      ConfigLoader.load_config()
      assert {:ok, %{route_info: ^expected_split}} = find_proxy_pass(uri_split)
    end
  end
end
