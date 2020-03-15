defmodule ServiceGateway.SelectorWorker do
  @moduledoc false
  use GenServer
  require Logger
  alias ServiceGateway.ProxyPass
  alias ServiceGateway.ProxyPass.Destination
  alias ServiceGateway.Utils.TimeMachine
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

  @spec notify_destination_status(pid(), ProxyPass.t(), Destination.t(), :healthy | :unhealthy) ::
          none()
  def notify_destination_status(server, proxy_pass, destination, status) do
    GenServer.cast(server, {proxy_pass, destination, status})
  end

  # ===== Callbacks =====
  @doc """
  Starts and links server. Argument is list of ProxyPass configuration.
  """
  @spec start_link([ProxyPass.t()]) :: GenServer.on_start()
  def start_link(config) do
    GenServer.start_link(__MODULE__, config, [])
  end

  @doc """
  Inits server. Argument is list of ProxyPass configuration.
  """
  @spec start_link([ProxyPass.t()]) :: GenServer.on_start()
  @impl true
  def init(config) do
    init_state =
      Enum.reduce(
        config,
        %{},
        fn proxy_pass, acc ->
          Map.put(acc, proxy_pass.name, init_destination_state(proxy_pass.destinations))
        end
      )

    Logger.debug("Init state for the selector: " <> inspect(init_state))
    {:ok, init_state}
  end

  defp init_destination_state(destinations) do
    statuses =
      Enum.reduce(
        destinations,
        %{},
        fn dest, acc ->
          Map.put(acc, dest.id, %{events: [], status: :healthy})
        end
      )

    %{count: 0, statuses: statuses}
  end

  @impl true
  def handle_call(proxy_pass, _from, state) do
    {count, updated_state} = inc_and_get(proxy_pass.name, proxy_pass.destinations, state)

    case filter_failed_destinations(proxy_pass.name, proxy_pass.destinations, state) do
      [] ->
        {:reply, {:error, "All destinations are unavailable"}, updated_state}

      _ ->
        dest = do_select(proxy_pass.destinations, count)
        {:reply, {:ok, dest}, updated_state}
    end
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

  defp filter_failed_destinations(proxy_pass_name, destinations, state) do
    proxy_state = state[proxy_pass_name]

    if !proxy_state do
      Logger.error("Can't find proxy pass '#{proxy_pass_name}'!")
      destinations
    else
      statuses = proxy_state.statuses

      Enum.filter(
        destinations,
        fn d ->
          case Map.get(statuses, d.id) do
            %{status: status} ->
              status == :healthy

            nil ->
              Logger.error("Can't find destination '#{d}'!")
              true
          end
        end
      )
    end
  end

  defp inc_and_get(proxy_pass_name, destinations, state) do
    weights_sum = weights_sum(destinations)
    proxy_state = state[proxy_pass_name]

    if !proxy_state do
      Logger.error("Can't find proxy state '#{proxy_state}'!")
      {0, state}
    else
      count = rem(proxy_state.count + 1, weights_sum)
      updated_proxy_state = %{proxy_state | count: count}
      updated = %{state | proxy_pass_name => updated_proxy_state}
      {count, updated}
    end
  end

  @impl true
  def handle_cast({proxy_pass, destination, new_status}, state) do
    {:noreply, update_status(proxy_pass, destination, new_status, state)}
  end

  defp update_status(proxy_pass, destination, new_status, state) do
    destination_status = Map.get(state, proxy_pass.name)
    %{events: events, status: current} = Map.get(destination_status, destination.id)

    should_be_after =
      TimeMachine.utc_now_millis() - destination.threshold_interval

    updated_events =
      [{new_status, TimeMachine.utc_now_millis()} | events]
      |> Enum.filter(fn {_, t} -> t >= should_be_after end)
      |> Enum.take(destination.healthy_threshold + destination.failed_threshold)

    last_series_length =
      Enum.take_while(updated_events, fn {status, _} -> status == new_status end)
      |> length

    updated_status =
      cond do
        new_status == :healthy and last_series_length >= destination.healthy_threshold ->
          :healthy

        new_status == :unhealthy and last_series_length >= destination.failed_threshold ->
          :unhealthy
      end

    updated_destination_status = %{
      destination_status
      | :events => updated_events,
        :status => updated_status
    }

    %{state | proxy_pass.name => updated_destination_status}
  end
end
