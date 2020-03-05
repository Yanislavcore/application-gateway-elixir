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
          route: ["/test/foo/"],
          destinations: []
        }
      ]
    },
    {
      "/test/foo/",
      "/test/",
      [
        %{
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
          route: ["/bar", "/test", "/test/foo/"],
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
      assert {:ok, {^expected_split, _}} = find_destination(uri_split)
    end
  end
end
