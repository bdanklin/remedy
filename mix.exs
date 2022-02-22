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
      deps: deps() ++ dev_deps(),
      dialyzer: [plt_add_deps: :app_tree, plt_add_apps: [:mix], list_unused_filters: true],
      docs: docs(),
      aliases: aliases(),
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
      # Remedy
      # Remedy.API,
      # Remedy.Buffer,
      # Remedy.Cache
      # Remedy.CDN
      # Remedy.Consumer,
      # Remedy.Dispatch,
      Constructors: [
        Remedy.Embed,
        Remedy.AllowedMentions,
        Remedy.Content,
        Remedy.Attachment
      ],
      "Consuming Events": [
        Remedy.Consumer,
        Remedy.Consumer.Metadata,
        Remedy.Consumer.Producer
      ],
      Gateway: [
        Remedy.Gateway,
        Remedy.Gateway.Intents
      ],
      Voice: [
        Remedy.Voice
      ],
      Types: [
        Remedy.Colour,
        Remedy.Flag,
        Remedy.ImageData,
        Remedy.ISO8601,
        Remedy.Snowflake,
        Remedy.Timestamp,
        Remedy.Type,
        Remedy.URL,
        Remedy.Locale
      ],
      "Schema & Fields": [
        ~r/Remedy.Schema/
      ],
      Helpers: [
        Remedy.TimeHelpers,
        Remedy.ColourHelpers,
        Remedy.ResourceHelpers,
        Remedy.CastHelpers
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
      Schema: &(&1[:section] == :schema),
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
      ## Web
      {:gun, "2.0.1", hex: :remedy_gun},
      {:certifi, "~> 2.8"},
      ## Data Processing
      {:broadway, "~> 1.0.2"},
      ## DB & Parsing
      {:jason, "~> 1.3"},
      {:ecto, "~> 3.7"},
      {:etso, "~> 0.1.6"},
      {:mime, "~> 2.0"},
      ## Voice
      {:kcl, "~> 1.4"},
      ## Rate Limiter
      {:ex_rated, "~> 2.0"},
      # TODO: Take what we need and remove
      {:ecto_morph, "~> 0.1.25"}
    ]
  end

  defp dev_deps do
    ## Dev / Test Only
    [
      # {:ex_doc, "~> 0.27.4", only: [:dev], hex: :remedy_exdoc, runtime: false},
      {:ex_doc, "~> 0.28.1", only: [:dev], github: "/bdanklin/ex_doc", runtime: false},
      {:ex_check, "~> 0.14.0", only: [:dev], runtime: false},
      {:mix_unused, "~> 0.2.0", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:credo, "~> 1.6.2", only: [:dev], runtime: false},
      {:doctor, "~> 0.18.0", only: [:dev], runtime: false},
      {:benchee, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    []
  end
end
