defmodule ServiceGateway.SelectorWorkerTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias ServiceGateway.SelectorWorker
  alias ServiceGateway.ProxyPass
  alias ServiceGateway.ProxyPass.Destination

  setup context do
    selector = start_supervised!({ServiceGateway.SelectorWorker, name: context.test})
    %{selector: selector}
  end

  test "selector worker should return as weighted", %{selector: selector} do
    destinations = [
      %Destination{id: "foo-0", url: "http://bar0/", weight: 1},
      %Destination{id: "foo-1", url: "http://bar1/", weight: 2},
      %Destination{id: "foo-2", url: "http://bar2/", weight: 3}
    ]
    proxy_pass = %ProxyPass{name: "foo", route_info: "bar", destinations: destinations}

    [f, s, t] = destinations
    expected = [f, s, s, t, t, t]
               |> List.duplicate(5)
               |> List.flatten()

    actual = for _ <- 0..29 do
      elem(SelectorWorker.select_destination(selector, proxy_pass), 1)
    end

    assert actual == expected
  end
end
