defmodule ServiceGateway.Selector do
  @moduledoc false

  alias ServiceGateway.ProxyPass
  alias ServiceGateway.SelectorWorker
  alias ServiceGateway.ProxyPass.Destination
  import ServiceGateway.Utils.Constants, only: [selector_pool_name: 0]
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
        SelectorWorker.select_destination(
          s,
          proxy_pass,
          timeout - (System.monotonic_time(:millisecond) - start)
        )
      end,
      timeout
    )
  end

  @spec notify_destination_status(ProxyPass.t(), Destination.t(), :healthy | :unhealthy) :: none()
  def notify_destination_status(proxy_pass, destination, status) do
    :poolboy.transaction(
      selector_pool_name(),
      fn s -> SelectorWorker.notify_destination_status(s, proxy_pass, destination, status) end,
      500
    )
  end
end
