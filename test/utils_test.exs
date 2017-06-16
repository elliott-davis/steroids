defmodule UtilsTest do
  use ExUnit.Case
  doctest Utils
  describe "Utils.boolMerge/1" do
    test "should do nothing with a single query" do
      q = [{:bool, :somequery, :must, %{} }]
      result = Utils.boolMerge(q)
      assert %{ somequery: %{} } == result
    end

    test "should combine two queries into a bool" do
      queries = [{:bool, :term, :must, %{ user: "me" } },
                  {:bool, :term, :must, %{ user: "him" } }]

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
        queries = [{:bool, :term, :must, %{ user: "me" } },
                  {:bool, :term, :must_not, %{ user: "you" } },
                  {:bool, :term, :must, %{ user: "him" } }]

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
    test "should merge opts and field when field is an object" do
      expected = %{user: "me", opts: "bar"}
      actual = Utils.buildClause(%{user: "me"}, nil, %{opts: "bar"})
      assert expected == actual
    end

    test "should merge opts when field is an atom and value is nil" do
      expected = %{field: "user", opts: "bar"}
      actual = Utils.buildClause("user", nil, %{opts: "bar"})
      assert expected == actual
    end

    test "should merge opts when field is an atom and value is defined" do
      expected = %{user: "me", opts: "bar"}
      actual = Utils.buildClause(:user, "me", %{opts: "bar"})
      assert expected == actual
    end

    test "should format clause with an array value" do
      users = ["you", "me", "irene"]
      expected = %{ users: users }
      actual = Utils.buildClause(:users, users)
      assert expected == actual
    end
  end
end
