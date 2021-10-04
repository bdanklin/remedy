  Simple Ratelimiter implementation.

  Due to limitations and the dynamic nature of the Discord ratelimit system, it is not possible to know the ratelimits of given routes beforehand.

  There are several types of rate limits at play:
  - A global ratelimit of 50 requests per second must be respected.
  - Route specific ratelimits are dynamic and can change, they can also be shared across routes. These are only known after a request has been sent.
  - Hidden ratelimits against specific resources. (Will error and not provide an accurate ratelimit. These are known to be applied to Emojis and deleting older messages.)

  This module keeps a state of

  ```elixir
  %{
    "route1" => {bucket1, reset1, limit1},
    "route2" => {bucket2, reset2, limit2},
    "route3" => {bucket3, reset3, limit3}
  }```

  - A route will be added to the state whenever the headers are recieved from a successful request.
  - Global ratelimit will be updated regardless of the success of a request.
  """
