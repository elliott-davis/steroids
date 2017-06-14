defmodule UtilsTest do
  use ExUnit.Case
  doctest Utils

  test "should do nothing with a single query" do
    q = [{:bool, :must, %{ somequery: %{} }}]
    result = Utils.boolMerge(q)
    assert %{ somequery: %{} } == result
  end

  test "should combine two queries into a bool" do
    queries = [{:bool, :must, %{ term: %{ user: "me" } } },
                {:bool, :must, %{ term: %{ user: "him" } } }]

    expected = %{
        bool: %{
          must: [
            %{ term: %{ user: "me" } },
            %{ term: %{ user: "him" } }
          ]
        }
      }

    actual = Utils.boolMerge(queries)

    assert expected == actual
  end

  test "should combine two queries accounting for boolType" do
      queries = [{:bool, :must, %{ term: %{ user: "me" } } },
                {:bool, :must_not, %{ term: %{ user: "you" } } },
                {:bool, :must, %{ term: %{ user: "him" } } }]

      expected = %{
        bool: %{
          must: [
            %{ term: %{ user: "me" } },
            %{ term: %{ user: "him" } }
          ],
          must_not: [
            %{ term: %{ user: "you" } },
          ]
        }
      }

      actual = Utils.boolMerge(queries)

      assert expected == actual
  end
end
