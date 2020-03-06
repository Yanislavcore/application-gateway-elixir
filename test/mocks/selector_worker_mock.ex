defmodule SelectorWorkerMock do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, {:ok, :stubbed}, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end