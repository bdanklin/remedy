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
      assets: "hello/images",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      main: "introduction",
      extra_section: "HELLO",
      nest_modules_by_prefix: nest_for_modules(),
      groups_for_modules: groups_for_modules(),
      groups_for_functions: groups_for_functions(),
      before_closing_body_tag: &before_closing_body_tag/1
    ]
  end

  def extras do
    [
      "hello/introduction/configuration.md",
      "hello/introduction/getting_started.md"
    ]
  end

  def groups_for_extras() do
    [
      Introduction: ~r/hello\/introduction\/.?/,
      #  Guides: ~r/hello\/[^\/]+\.md/,
      Authentication: ~r/hello\/authentication\/.?/,
      "Real-time": ~r/hello\/real_time\/.?/,
      Testing: ~r/hello\/testing\/.?/,
      Deployment: ~r/hello\/deployment\/.?/,
      "How-to's": ~r/hello\/howto\/.?/
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
        Remedy.URL
      ],
      "Schema & Fields": [
        ~r/Remedy.Schema/
      ],
      Helpers: [
        Remedy.CaseHelpers,
        Remedy.CastHelpers,
        Remedy.ColourHelpers,
        Remedy.ColourHelpers.Palette,
        Remedy.EctoHelpers,
        Remedy.ResourceHelpers,
        Remedy.TimeHelpers
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

  defp before_closing_body_tag(:html) do
    """
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script>mermaid.initialize({startOnLoad: true})</script>
    """
  end

  defp before_closing_body_tag(_), do: ""

  def package do
    [
      name: @app,
      licenses: @license,
      maintainers: @maintainers,
      links: %{
        "GitHub" => @scm_url
      },
      files: ~w(lib mix.exs README.md .formatter.exs remedy.png remedy_banner.png)
    ]
  end

  defp deps do
    [
      {:gun, "2.0.1", hex: :remedy_gun},
      {:certifi, "~> 2.8"},
      {:broadway, "~> 1.0.2"},
      {:jason, "~> 1.3"},
      {:ecto, "~> 3.7"},
      {:etso, "~> 0.1.6"},
      {:phoenix_pubsub, "~> 2.0"},
      {:ex_rated, "~> 2.0"},
      # TODO: Take what we need and remove
      {:mime, "~> 2.0"},
      {:ecto_morph, "~> 0.1.25"}
    ]
  end

  defp dev_deps do
    ## Dev / Test Only
    [
      {:ex_doc, "~> 0.28.2", only: [:dev], hex: :remedy_exdoc, runtime: false},
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
