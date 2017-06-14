defmodule UtilsTest do
  use ExUnit.Case
  doctest Utils
  describe "Utils.boolMerge/1" do
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

  describe "Utils.buildClause/3" do
    test "should merge when field is a map and value is nil" do
      expected = %{term: :user, opts: "bar"}
      actual = Utils.buildClause(%{term: :user}, nil, %{opts: "bar"})
      assert expected == actual
    end

    test "should merge when field is an atom and value is nil" do
      expected = %{field: :user, opts: "bar"}
      actual = Utils.buildClause(:user, nil, %{opts: "bar"})
      assert expected == actual
    end

    test "should merge when field is an atom and value is defined" do
      expected = %{term: :user, opts: "bar"}
      actual = Utils.buildClause(:term, :user, %{opts: "bar"})
      assert expected == actual
    end
  end
end
