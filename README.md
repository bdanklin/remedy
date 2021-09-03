## Notes

- [ ] Separate applicable components into their own package.
  - [ ] Types - Timestamp / Snowflake
- [ ] Convert structs to Ecto Schema.
- [ ] Cache
  - [ ] Generalize. choose what to cache based on your resources.
  - [ ] Make it an actual cache, aka invisible and if the resource is not in cache, we should fetch it and return it as required.
- [ ] Testing
  - [ ] Supply a bot secret thru workflow to enable actual testing on a real server. without exposing secrets (prob too hard)

## Installation

I do not recommend anybody install this, instead you should probably use [Remedy](https://github.com/bdanklin/remedy)

## License
[MIT](https://opensource.org/licenses/MIT)
