defmodule Remedy.MixProject do
  use Mix.Project

  @version "0.5.0"
  @scm_url "https://github.com/bdanklin/remedy"
  @doc_url "https://bdanklin.github.io/remedy/"

  def project do
    [
      app: :remedy,
      version: @version,
      elixir: "~> 1.11",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      name: "Remedy",
      source_url: @scm_url,
      homepage_url: @doc_url,
      deps: deps(),
      docs: docs(),
      dialyzer: dialyzer(),
      aliases: aliases(),
      description: """
      Discord Library in Elixir.
      """
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      logo: "remedy.png",
      assets: "guides/assets",
      extras: extras(),
      groups_for_modules: groups_for_modules()
    ]
  end

  def extras do
    [
      "docs/static/API.md"
    ]
  end

  def groups_for_modules do
    [
      Api: [
        ~r/Remedy.Api/
      ],
      Cache: [
        ~r/Remedy.Cache/
      ],
      Structs: [
        ~r/Remedy.Struct/
      ]
    ]
  end

  # defp elixirc_paths(:test), do: ["lib", "test"]
  # defp elixirc_paths(_), do: ["lib"]

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
        "GitHub" => @scm_url,
        "Docs" => @doc_url
      },
      files: ~w(lib mix.exs README.md .formatter.exs)
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
      {:credo, "~> 1.4"},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
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
