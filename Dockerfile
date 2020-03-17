#### GLOBAL ####
ARG BUILD_ENV=prod

#### BUILD ####

FROM elixir:1.10.2 AS build
ADD . /sources/
WORKDIR /sources/
ENV MIX_ENV=$BUILD_ENV
RUN mix local.hex --force && mix local.rebar --force && mix deps.get && mix release

#### APP ####

FROM debian:10.3

ENV LANG=C.UTF-8
WORKDIR /app/
RUN apt update && apt install openssl -y
COPY --from=build /sources/_build/$BUILD_ENV/rel/service_gateway /app/
CMD /app/bin/service_gateway start