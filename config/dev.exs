import Config

config :service_gateway,
  port: 8080,
  routes: [
    %{
      name: "postman_echo",
      route: ["/get_echo"],
      destinations: [
        %{url: "https://postman-echo.com/get", weight: 1},
        %{url: "https://postman-echo.com/get", weight: 1}
      ]
    },
    %{
      name: "postman_echo",
      route: ["/post_echo"],
      destinations: [
        %{url: "https://postman-echo.com/post", weight: 1},
        %{url: "https://postman-echo.com/post", weight: 1}
      ]
    }
  ]
