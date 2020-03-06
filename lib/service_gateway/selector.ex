defmodule ServiceGateway.Selector do
  @moduledoc false

  alias ServiceGateway.ProxyPass
  alias ServiceGateway.SelectorWorker
  alias ServiceGateway.ProxyPass.Destination
  import ServiceGateway.Application, only: [selector_pool_name: 0]
  # ===== Public API =====
  @doc """
  Selects one of the available destinations from list and returns it `{:ok, "<url>"}`.
  If all of the destinations are unavailable returns error `{:error, "Destinations are unavailable"}`
  """
  @spec select_destination(ProxyPass.t(), timeout()) ::
          {:ok, Destination.t()} | {:error, String.t()}
  def select_destination(proxy_pass, timeout \\ 500) do
    start = System.monotonic_time(:millisecond)
    :poolboy.transaction(
      selector_pool_name(),
      fn s ->
        SelectorWorker.select_destination(s, proxy_pass, timeout - (System.monotonic_time(:millisecond) - start))
      end,
      timeout
    )
  end

end
