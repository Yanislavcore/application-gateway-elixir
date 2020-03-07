defmodule ServiceGateway.Utils.Constants do
  @moduledoc false

  def selector_pool_name do
    Application.fetch_env!(:service_gateway, :constants).selector_pool_name
  end
end
