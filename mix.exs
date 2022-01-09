defmodule Remedy.MixProject do
  use Mix.Project

  @app :remedy
  @name "Remedy"
  @version "0.6.9"
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
      dialyzer: [plt_add_deps: :app_tree, plt_add_apps: [:mix]],
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :jason],
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
      groups_for_modules: groups_for_modules(),
      groups_for_functions: groups_for_functions()
    ]
  end

  def extras do
    [
      "hello/introduction.md",
      "hello/getting_started.md"
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
      # CDN: [Remedy.CDN],
      # "REST API": [Remedy.API],
      Constructors: [
        Remedy.Embed
      ],
      Gateway: [
        Remedy.Consumer,
        Remedy.Gateway,
        Remedy.Gateway.Intents
      ],
      Schema: [~r/Remedy.Schema/],
      Types: [
        Remedy.ISO8601,
        Remedy.Colour,
        Remedy.Snowflake,
        Remedy.Flag,
        Remedy.Timestamp
      ],
      Helpers: [
        Remedy.TimeHelpers,
        Remedy.OpcodeHelpers,
        Remedy.DateHelpers,
        Remedy.ColourHelpers
      ]
    ]
  end

  def groups_for_functions do
    [
      #      Interactions: &(&1[:section] == :interactions),
      #      Commands: &(&1[:section] == :commands),
      #      Stickers: &(&1[:section] == :stickers),
      #      Emojis: &(&1[:section] == :emojis),
      #      Reactions: &(&1[:section] == :reactions),
      Guards: &(&1[:section] == :guards)
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
      ## Dev / Test Only
      {:ex_doc, "~> 0.27.4", only: [:dev], hex: :remedy_exdoc, runtime: false},
      {:ex_check, "~> 0.14.0", only: [:dev], runtime: false},
      {:mix_unused, "~> 0.2.0", only: [:dev]},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:credo, "~> 1.5.6", only: [:dev], runtime: false},
      {:doctor, "~> 0.18.0", only: [:dev]},
      {:faker, "~> 0.17", only: [:test, :dev]},
      ## Web
      {:gun, "2.0.1", hex: :remedy_gun},
      ## Unsafe Function Bindings !
      {:unsafe, "~> 1.0"},
      ## Rate Limiter
      {:ex_rated, "~> 2.0"},
      ## CLI
      {:progress_bar, "~> 2.0"},
      ## Data Processing
      {:gen_stage, "~> 1.0"},
      ## DB, Casting & Parsing
      {:jason, "~> 1.2"},
      {:ecto, "~> 3.7"},
      {:ecto_morph, "~> 0.1.25"},
      {:etso, "~> 0.1.6"},
      {:morphix, "~> 0.8.1"},
      {:mime, "~> 2.0"},
      {:exmoji, "~> 0.3.0"},
      {:recase, "~> 0.7.0"},
      ## Timezone
      {:tz, "~> 0.20.1"}
    ]
  end
end
