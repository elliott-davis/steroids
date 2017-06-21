defmodule UtilsTest do
  use ExUnit.Case
  import Steroids.Utils, only: [boolMerge: 1, buildClause: 1]
  doctest Steroids.Utils
  describe "Utils.boolMerge/1" do
    test "should do nothing with a single query" do
      q = [{:query, :somequery, :must, %{} }]
      result = boolMerge(q)
      assert %{ somequery: %{} } == result
    end

    test "should combine two queries into a bool" do
      queries = [{:query, :term, :must, %{ user: "me" } },
                  {:query, :term, :must, %{ user: "him" } }]

      expected = %{
        bool: %{
          must: [
            %{ term: %{ user: "me" } },
            %{ term: %{ user: "him" } }
          ]
        }
      }

      actual = boolMerge(queries)

      assert expected == actual
    end

    test "should render bool for single should query" do
      queries = [{:query, :term, :should, %{ user: "me" } }]
      expected = %{
        bool: %{
          should: [
            %{ term: %{ user: "me" } }
          ]
        }
      }
      actual = boolMerge(queries)
      assert expected == actual
    end

    test "should render bool for single must_not query" do
      queries = [{:query, :term, :must_not, %{ user: "me" } }]
      expected = %{
        bool: %{
          must_not: [
            %{ term: %{ user: "me" } }
          ]
        }
      }
      actual = boolMerge(queries)
      assert expected == actual
    end

    test "should combine two queries accounting for boolType" do
        queries = [{:query, :term, :must, %{ user: "me" } },
                  {:query, :term, :must_not, %{ user: "you" } },
                  {:query, :term, :must, %{ user: "him" } }]

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

        actual = boolMerge(queries)

        assert expected == actual
    end
  end

  describe "Utils.buildClause/3" do
    test "should merge opts and field when field is an object" do
      expected = %{user: "me", opts: "bar"}
      actual = buildClause(field: %{user: "me"}, args: %{opts: "bar"})
      assert expected == actual
    end

    test "should merge opts when field is an atom and value is nil" do
      expected = %{field: "user", opts: "bar"}
      actual = buildClause(field: "user", args: %{opts: "bar"})
      assert expected == actual
    end

    test "should merge opts when field is an atom and value is defined" do
      expected = %{user: "me", opts: "bar"}
      actual = buildClause(field: :user, value: "me", args: %{opts: "bar"})
      assert expected == actual
    end

    test "should format clause with an array value" do
      users = ["you", "me", "irene"]
      expected = %{ users: users }
      actual = buildClause(field: :users, value: users)
      assert expected == actual
    end
  end
end
