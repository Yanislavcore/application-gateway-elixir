defmodule ServiceGateway.MixProject do
  use Mix.Project

  def project do
    [
      app: ServiceGateway.Application,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cachex, :poolboy],
      mod: {ServiceGateway.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.1"},
      {:cachex, "~> 3.2"},
      {:mojito, "~> 0.6.1"},
      {:poolboy, "~> 1.5"}
    ]
  end
end
