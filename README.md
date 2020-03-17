# Application Gateway  
  
Portfolio project of a simple but scalable application gateway / reverse proxy project written in Elixir.

## Startup

1. Clone this repo
2. Edit configuration
3. Build release or docker image
4. Run 

### Configuration

Release configuration is stored in `config/releases.exs` in sources 
or in `releases/0.1.0/releases.exs` in already built release bundle.

Example configuration:

```elixir
import Config

config :service_gateway,
       # (Required) Port of gateway
       port: 8080,
       # (Required) Routes list
       routes: [
         %{
           # (Required) Name of route.
           name: "postman_echo",
           # (Required) List of urls that should be routed to specified destinations.
           route: ["/get_echo"],
           # (Required) List of destinations.
           # Traffic is balanced in a round-robin manner between healthy destinations according to the weights.
           destinations: [
             %{
               # (Required) Destination url.
               url: "https://postman-echo.com/get",
               # (Optional) Destination timeout in ms. Default: 10000.
               timeout: 5000,
               # (Optional) Health check url. Defaults to destination url.
               healthcheck_url: "https://postman-echo.com/get",
               # (Optional) Health check interval. Interval between health check calls. Default: 5000.
               healthcheck_interval: 2000,
               # (Optional) The interval during which the threshold value for changing the status must be reached.
               # Default: 15000.
               threshold_interval: 10000,
               # (Optional) Healthy status threshold.
               healthy_threshold: 1,
               # (Optional) Unhealthy status threshold.
               failed_threshold: 1,
               # (Optional) Weight of the destination
               weight: 1
             }
           ]
         }
       ]

``` 

### Build and run

#### From source
Requrements:
* Elixir 1.10.2 + mix
* Erlang 10.6.4 + rebar3

You can build service manually by running the following.
```
MIX_ENV=prod && mix clean && mix deps.get && mix release
cd _build/prod/rel/service_gateway
bin/service_gateway start
``` 

#### Docker image

Only Docker (>=17.05) is required. Just run:
```
docker build . -t yanislavcore/application_gateway:snapshot
docker run -d --name application_gateway yanislavcore/application_gateway:snapshot
```
