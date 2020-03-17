defmodule ServiceGateway.Utils.TimeMachine do
  @moduledoc false

  @doc """
  Returns current Unix time in milliseconds.
  """
  @spec utc_now_millis() :: non_neg_integer()
  def utc_now_millis() do
    DateTime.to_unix(DateTime.utc_now(), :millisecond)
  end
end
