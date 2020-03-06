defmodule ServiceGateway.SelectorTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias ServiceGateway.Selector
  import ServiceGateway.Application, only: [selector_pool_name: 0]

  setup do
    pool_config = [
      name: {:local, selector_pool_name()},
      worker_module: SelectorWorkerMock,
      size: 1,
      strategy: :fifo
    ]

    spec = %{
      id: selector_pool_name(),
      start: {:poolboy, :start_link, [pool_config, []]},
      shutdown: 5000,
      type: :worker,
      modules: [:poolboy]
    }

    _ = start_supervised!(spec)
    %{}
  end

  test "should call stubbed method" do
    assert Selector.select_destination({}, 1000) == {:ok, :stubbed}
  end
end
