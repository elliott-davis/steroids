defmodule SteroidsTest do
  use ExUnit.Case

  doctest Steroids

  test "should merge a single query and filter" do
    expected = %{
      query: %{
        bool: %{
          must: %{
            match: %{
              message: "this is a test"
            }
          },
          filter: %{
            term: %{user: "kimchy"}
          }
        }
      }
    }
    actual = []
    |> Steroids.QueryBuilder.query(:match, field: :message, value: "this is a test")
    |> Steroids.FilterBuilder.filter(:term, field: :user, value: "kimchy")
    |> Steroids.build()

    assert expected == actual
  end

  test "should merge multiple queries and filters" do
    expected = %{
      query: %{
        bool: %{
          must: [
            %{ match: %{ message: "this is a test" } },
            %{ term: %{ user: "test"} }
          ],
          filter: %{
            term: %{user: "kimchy"}
          }
        }
      }
    }
    actual = []
    |> Steroids.QueryBuilder.query(:term, field: :user, value: "test")
    |> Steroids.QueryBuilder.query(:match, field: :message, value: "this is a test")
    |> Steroids.FilterBuilder.filter(:term, field: :user, value: "kimchy")
    |> Steroids.build()

    assert expected == actual
  end
end
