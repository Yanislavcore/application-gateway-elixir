import Config

config :logger, :console,
  format: "[$level] $metadata$message\n",
  metadata: [:module, :function, :my_id]

config :service_gateway,
  port: 8080,
  rate_limiting: %{
    windows: 3,
    window_length_millis: 20000,
    limit: 20,
    cache_entries_limit: 200_000
  },
  routes: [
    %{
      name: "postman_echo",
      route: ["/get_echo"],
      timeout: 5000,
      destinations: [
        %{url: "https://postman-echo.com/get", weight: 1},
        %{url: "https://postman-echo.com/get", weight: 1}
      ]
    },
    %{
      name: "postman_echo",
      route: ["/post_echo"],
      timeout: 5000,
      destinations: [
        %{url: "https://postman-echo.com/post", weight: 1},
        %{url: "https://postman-echo.com/post", weight: 1}
      ]
    }
  ]
