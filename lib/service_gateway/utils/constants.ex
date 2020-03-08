defmodule ServiceGateway.Utils.Constants do
  @moduledoc false

  def selector_pool_name do
    Application.fetch_env!(:service_gateway, :constants).selector_pool_name
  end

  def destination_status_table_name do
    Application.fetch_env!(:service_gateway, :constants).destination_status_table_name
  end
end
