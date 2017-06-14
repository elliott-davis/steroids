defmodule SteroidsTest do
  use ExUnit.Case
  doctest Steroids

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
    actual = QueryBuilder.queryMinimumShouldMatch(query, 5)
    assert expected == actual
  end
end
