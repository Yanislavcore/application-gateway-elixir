import Config

config ServiceGateway.Application,
  port: 8080,
  rate_limiting: %{
    windows: 3,
    window_length_millis: 20000,
    limit: 20,
    cache_entries_limit: 200_000
  },
  routes: [
    %{
      route: ["/get_echo"],
      destinations: [
        %{url: "https://postman-echo.com/get", weight: 1},
        %{url: "https://postman-echo.com/get", weight: 1}
      ]
    }
  ]
