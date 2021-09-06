[
  import_deps: [:ecto],
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
    quote: :*
    unquote: :*
  ]
]
