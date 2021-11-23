defmodule Remedy.MixProject do
  @moduledoc false
  use Mix.Project

  @app :remedy
  @name "Remedy"
  @version "0.6.8"
  @scm_url "https://github.com/bdanklin/remedy"
  @doc_url "https://bdanklin.github.io/remedy/"
  @description "Discord Library in Elixir."
  @license ["MIT"]
  @maintainers ["Benjamin Danklin"]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.12",
      name: @name,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @scm_url,
      homepage_url: @doc_url,
      description: @description,
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets],
      mod: {Remedy, []}
    ]
  end

  def docs do
    [
      source_ref: "master",
      logo: "remedy.png",
      assets: "guides/assets",
      extras: extras(),
      main: "introduction",
      extra_section: "HELLO",
      nest_modules_by_prefix: nest_for_modules(),
      groups_for_modules: groups_for_modules()
    ]
  end

  def extras do
    [
      "hello/introduction.md"
    ]
  end

  def nest_for_modules do
    [
      Remedy.Gateway.Dispatch,
      Remedy.Schema
    ]
  end

  def groups_for_modules do
    [
      Schema: [
        ~r/Remedy.Schema/
      ],
      Exceptions: [
        Remedy.EnvironmentVariableError,
        Remedy.VoiceError,
        Remedy.CacheError,
        Remedy.APIError
      ]
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
      {:ex_check, "~> 0.14.0", only: [:dev], runtime: false},
      {:mix_unused, "~> 0.2.0", only: [:dev]},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:credo, "~> 1.5.6", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.15", only: [:dev]},
      {:recon, "~> 2.3", only: [:dev]},
      {:doctor, "~> 0.18.0", only: [:dev]},
      {:map_diff, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ecto_morph, "~> 0.1.25"},
      {:unsafe, "~> 1.0"},
      {:ex_rated, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:mime, "~> 2.0"},
      {:progress_bar, "~> 2.0"},
      {:gun, "2.0.1", hex: :remedy_gun},
      {:gen_stage, "~> 1.0"},
      {:ecto, "~> 3.7"},
      {:etso, "~> 0.1.6"},
      {:sunbake, "~> 0.2.4"},
      {:battle_standard, "~> 0.1.0"},
      {:morphix, "~> 0.8.1"},
      {:recase, "~> 0.7.0"}
    ]
  end

  def dialyzer do
    [plt_add_deps: :app_tree, plt_add_apps: [:mix]]
  end
end
