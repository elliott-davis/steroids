defmodule QueryBuilderTest do
  use ExUnit.Case
  import Steroids.QueryBuilder, only: [queryMinimumShouldMatch: 2, query: 2, getQuery: 1]
  doctest Steroids.QueryBuilder

  test "Correctly set the query minimum to match" do
    query = %{
      bool: %{
        should: [
          %{ term: %{ user: "me" } },
          %{ term: %{ user: "you" } }
        ]
      }
    }
    expected = %{
      bool: %{
        minimum_should_match: 5,
        should: [
          %{ term: %{ user: "me" } },
          %{ term: %{ user: "you" } }
        ]
      }
    }
    actual = queryMinimumShouldMatch(query, 5)
    assert expected == actual
  end

  test "query" do
    expected = %{ match_all: %{} }
    actual = Steroids.QueryBuilder.new
    |> query(:match_all)
    |> getQuery
    assert expected == actual
  end
end
