defmodule ServiceGateway.SelectorWorkerTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias ServiceGateway.SelectorWorker
  alias ServiceGateway.ProxyPass
  alias ServiceGateway.ProxyPass.Destination

  setup context do
    destinations = [
      %Destination{id: "foo-0", url: "http://bar0/", weight: 1},
      %Destination{id: "foo-1", url: "http://bar1/", weight: 2},
      %Destination{id: "foo-2", url: "http://bar2/", weight: 3}
    ]

    proxy_pass = %ProxyPass{name: "foo", route_info: "bar", destinations: destinations}

    spec = %{
      id: context.test,
      start: {ServiceGateway.SelectorWorker, :start_link, [[proxy_pass]]},
      shutdown: 5000,
      type: :worker,
      modules: [ServiceGateway.SelectorWorker]
    }

    selector = start_supervised!(spec)
    %{selector: selector, proxy_pass: proxy_pass}
  end

  test "selector worker should return as weighted", %{selector: selector, proxy_pass: proxy_pass} do
    expected_distribution = %{
      "foo-0" => 5,
      "foo-1" => 10,
      "foo-2" => 15
    }

    actual_distribution =
      1..30
      |> Enum.map(fn _ ->
        {:ok, dest} = SelectorWorker.select_destination(selector, proxy_pass)
        dest
      end)
      |> Enum.group_by(fn d -> d.id end)
      |> Enum.reduce(%{}, fn {id, destinations}, acc -> Map.put(acc, id, length(destinations)) end)

    assert actual_distribution == expected_distribution
  end
end
