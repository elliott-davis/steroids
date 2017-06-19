defmodule Steroids.Mixfile do
  use Mix.Project

  def project do
    [
      app: :steroids,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Steroids",
      source_url: "https://github.com/elliott-davis/steroids"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def description do
    """
    Steroids is an ElasticSearch query body builder adapted from [Bodybuilder](https://github.com/danpaz/bodybuilder).
    Easily build complex queries for elasticsearch with a simple, predictable api.
    """
  end

  def package do
    [
      name: :steroids,
      files: ["lib", "mix.exs", "LICENSE*", "README*"],
      licenses: ["Apache 2.0"],
      maintainers: ["Elliott Davis"],
      links: %{ "GitHub" => "https://github.com/elliott-davis/steroids" }
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
