# Steroids [WIP]

An elasticsearch query body builder adapted from [Bodybuilder](https://github.com/danpaz/bodybuilder).
Easily build complex queries for elasticsearch with a simple, predictable api.

## Usage
```
Steroids.QueryBuilder.query(:term, ["foo", "bar"])
|> Steroids.query(:term, "baz")
|> Steroids.build()
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `steroids` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:steroids, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/steroids](https://hexdocs.pm/steroids).
