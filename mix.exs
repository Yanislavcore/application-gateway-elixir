defmodule ServiceGateway.MixProject do
  use Mix.Project

  def project do
    [
      app: :service_gateway,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      aliases: [test: "test --no-start"],
      elixirc_paths: elixirc_paths(Mix.env()),
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
      {:poolboy, "~> 1.5"},
      {:mox, "~> 0.5", only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/mocks"]
  defp elixirc_paths(_), do: ["lib"]
end
