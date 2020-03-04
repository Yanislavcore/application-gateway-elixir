defmodule ServiceGateway.RateLimiterWorker do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({value, sleep}, _from, state) when is_integer(value) and is_integer(sleep) do
    Process.sleep(sleep)
    {:reply, {:ok, value * value}, state}
  end

  @impl true
  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end