defmodule Remedy.MixProject do
  use Mix.Project

  @app :remedy
  @name "Remedy"
  @version "0.5.2"
  @scm_url "https://github.com/bdanklin/remedy"
  @doc_url "https://bdanklin.github.io/remedy/"
  @description "Discord Library in Elixir."
  @license ["MIT"]
  @maintainers ["Benjamin Danklin"]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      name: @name,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @scm_url,
      homepage_url: @doc_url,
      description: @description,
      aliases: aliases(),
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      package: package()
      #    compilers: [:boundary, :phoenix, :gettext] ++ Mix.compilers(),
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets],
      mod: {Remedy.Application, []}
    ]
  end

  def docs do
    [
      source_ref: "master",
      logo: "remedy.png",
      assets: "guides/assets",
      extras: [
        "hello/introduction.md"
      ],
      main: "introduction",
      extra_section: "HELLO"
    ]
  end

  def aliases do
    [
      lint: ["format --check-formatted", "credo --strict"]
    ]
  end

  def package do
    [
      name: @app,
      licenses: @license,
      maintainers: @maintainers,
      links: %{
        "GitHub" => @scm_url
      },
      files: ~w(lib mix.exs README.md .formatter.exs remedy.png)
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.15", only: [:dev]},
      {:recon, "~> 2.3", only: [:dev]},
      # {:boundary, "~> 0.8.0", only: [:dev], runtime: false},
      {:httpoison, "~> 1.7"},
      {:poison, "~> 3.0"},
      {:gun, "~> 2.0", hex: :remedy_gun},
      {:kcl, "~> 1.4"},
      {:porcelain, "~> 2.0"},
      {:credo, "~> 1.4"},
      {:gen_stage, "~> 1.0"},
      {:unsafe, "~> 1.0"},
      {:ecto, "~> 3.7"},
      {:etso, "~> 0.1.6"},
      {:sunbake, "~> 0.2.0"},
      {:battle_standard, "~> 0.1.0"}
    ]
  end

  def dialyzer do
    [
      plt_add_deps: :app_tree,
      plt_add_apps: [:mix]
    ]
  end
end
