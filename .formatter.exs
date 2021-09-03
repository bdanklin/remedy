[
  inputs: ["mix.exs", "{config,examples,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    field: :*,
    belongs_to: :*,
    has_one: :*,
    has_many: :*,
    many_to_many: :*,
    embeds_one: :*,
    embeds_many: :*,

]
