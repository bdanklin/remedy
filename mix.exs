defmodule Remedy.Mixfile do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :remedy,
      version: "0.4.7",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "An elixir Discord library",
      package: package(),
      name: "Remedy",
      source_url: "https://github.com/bdanklin/remedy",
      homepage_url: "https://github.com/bdanklin/remedy",
      deps: deps(),
      dialyzer: dialyzer(),
      aliases: aliases(),
      lockfile: Path.expand("mix.lock", __DIR__),
      deps_path: Path.expand("deps", __DIR__),
      build_path: Path.expand("_build", __DIR__)
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger, :inets],
      mod: {Remedy.Application, []}
    ]
  end

  def aliases do
    [
      lint: ["format --check-formatted", "credo --strict"]
    ]
  end

  def package do
    [
      name: :remedy,
      licenses: ["MIT"],
      maintainers: ["Benjamin Danklin"],
      links: %{
        "GitHub" => "https://github.com/bdanklin/remedy/",
        "Docs" => "https://bdanklin.github.io/remedy/"
      }
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.7"},
      {:poison, "~> 3.0"},
      {:gun, "== 2.0.0-rc.2"},
      {:kcl, "~> 1.4"},
      {:porcelain, "~> 2.0"},
      {:ex_doc, "~> 0.15", only: :dev},
      {:credo, "~> 1.4", only: [:dev, :test]},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:gen_stage, "~> 1.0"},
      {:recon, "~> 2.3", only: :dev, optional: true}
    ]
  end

  def dialyzer do
    [
      plt_add_deps: :app_tree,
      plt_add_apps: [:mix]
    ]
  end
end
