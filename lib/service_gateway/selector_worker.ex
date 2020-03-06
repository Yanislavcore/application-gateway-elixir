defmodule ServiceGateway.SelectorWorker do
  @moduledoc false
  use GenServer
  alias ServiceGateway.ProxyPass
  alias ServiceGateway.ProxyPass.Destination
  # ===== Public API =====
  @doc """
  Selects one of the available destinations from list and returns it `{:ok, "<url>", call_wrapper}`.
  If all of the destinations are unavailable returns error `{:error, "Destinations are unavailable"}`
  """
  @spec select_destination(ProxyPass.t(), timeout()) ::
          {:ok, Destination.t()} | {:error, String.t()}
  def select_destination(server, proxy_pass, timeout \\ 500) do
    GenServer.call(server, proxy_pass, timeout)
  end

  @spec notify_destination_status(pid(), Destination.t(), :ok | :error) :: none()
  def notify_destination_status(server, destination, status) do
    GenServer.cast(server, {destination, status})
  end

  # ===== Callbacks =====
  @doc """
  Callback used by poolboy
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(proxy_pass, _from, state) do
    {count, updated_state} = inc_and_get(proxy_pass.name, proxy_pass.destinations, state)
    dest = do_select(proxy_pass.destinations, count)
    {:reply, {:ok, dest}, updated_state}
  end

  @impl true
  def handle_cast(_, state) do
    {:noreply, state}
  end

  defp do_select(destinations, count) do
    f = fn dest, x ->
      if x - dest.weight < 0 do
        {:halt, dest}
      else
        {:cont, x - dest.weight}
      end
    end

    Enum.reduce_while(destinations, count, f)
  end

  defp weights_sum(destinations) do
    Enum.reduce(destinations, 0, fn dest, sum -> sum + dest.weight end)
  end

  defp inc_and_get(proxy_pass_name, destinations, state) do
    weights_sum = weights_sum(destinations)
    proxy_sate = state[proxy_pass_name]

    if !proxy_sate do
      {0, Map.put(state, proxy_pass_name, %{count: 0, fails: [], success: []})}
    else
      count = rem(proxy_sate.count + 1, weights_sum)
      updated_proxy_state = %{proxy_sate | count: count}
      updated = %{state | proxy_pass_name => updated_proxy_state}
      {count, updated}
    end
  end
end
