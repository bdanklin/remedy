[
  line_length: 120,
  import_deps: [:ecto],
  plugins: [],
  inputs: [
    "*.{ex,exs}",
    "{config,lib,test}/**/*.{ex,exs}",
    "apps/**/{config,lib,test,repo}/**/*.{ex,exs}"
  ],
  locals_without_parens: [
    field: :*,
    belongs_to: :*,
    has_one: :*,
    has_many: :*,
    many_to_many: :*,
    embeds_one: :*,
    embeds_many: :*
  ]
]
