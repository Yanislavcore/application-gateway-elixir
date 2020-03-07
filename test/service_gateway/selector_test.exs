defmodule ServiceGateway.SelectorTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ServiceGateway.Selector

  setup do
    pool_name = :test_pool
    Application.put_env(:service_gateway, :constants, %{selector_pool_name: pool_name})

    pool_config = [
      name: {:local, pool_name},
      worker_module: GenServerMock,
      size: 1,
      strategy: :fifo
    ]

    spec = %{
      id: pool_name,
      start: {:poolboy, :start_link, [pool_config, []]},
      shutdown: 5000,
      type: :worker,
      modules: [:poolboy]
    }

    _ = start_supervised!(spec)
    %{}
  end

  test "should call stubbed method" do
    for _ <- 1..5 do
      assert Selector.select_destination({}, 1000) == {:ok, :stubbed}
    end
  end
end
