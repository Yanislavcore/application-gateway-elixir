import Config

config :logger, :console,
  format: "[$level] $metadata$message\n",
  metadata: [:module, :function, :my_id]

config :service_gateway,
  constants: %{
    selector_pool_name: :selector_pool,
    destination_status_table_name: :destination_status
  },
  port: 80,
  routes: []
