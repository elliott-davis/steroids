defmodule QueryBuilderTest do
  use ExUnit.Case
  import Steroids.QueryBuilder, only: [
    queryMinimumShouldMatch: 2,
    query: 2, query: 3,
    orQuery: 3, addQuery: 3, andQuery: 3,
    getQuery: 1]
  doctest Steroids.QueryBuilder

  describe "queryMinimumShouldMatch/2" do
    test "should set the minimum_should_match" do
      expected = %{
        bool: %{
          minimum_should_match: 5,
          should: [
            %{ term: %{ user: "me" } },
            %{ term: %{ user: "you" } }
          ]
        }
      }
      actual = []
      |> orQuery(:term, field: :user, value: "you")
      |> orQuery(:term, field: :user, value: "me")
      |> queryMinimumShouldMatch(5)
      |> getQuery

      assert expected == actual
    end

    test "should not set the minimum_should_match" do
      expected = %{
        bool: %{
          should: [
            %{ term: %{ user: "me" } },
          ]
        }
      }
      actual = Steroids.QueryBuilder.new
      |> orQuery(:term, field: :user, value: "me")
      |> queryMinimumShouldMatch(5)
      |> getQuery

      assert expected == actual
    end
  end
  describe "query/2" do
    test "when only a type is supplied" do
      expected = %{ match_all: %{} }
      actual = Steroids.QueryBuilder.new
      |> query(:match_all)
      |> getQuery
      assert expected == actual
    end
  end

  describe "query/3" do
    test "when a type is supplied with a field" do
      expected = %{ match_all: %{ boost: 1.2 } }
      actual = Steroids.QueryBuilder.new
      |> query(:match_all, field: %{ boost: 1.2 })
      |> getQuery
      assert expected == actual
    end

    test "when a type is supplied with a field and value" do
      expected = %{ match: %{ message: "this is a test" } }
      actual = Steroids.QueryBuilder.new
      |> query(:match, field: :message, value: "this is a test")
      |> getQuery
      assert expected == actual
    end

    test "when a type is supplied with a field and map value" do
      message = %{
        query: "this is a test",
        operator: "and"
      }
      expected = %{
        match: %{
          message: message
        }
      }
      actual = Steroids.QueryBuilder.new
      |> query(:match, field: :message, value: message)
      |> getQuery
      assert expected == actual
    end

    test "when a type is supplied with a field, value, and args" do
      opts = %{ fields: [ "content", "name"] }
      expected = %{
        query_string: %{
          query: "this is a test",
          fields: [ "content", "name"]
        }
      }
      actual = Steroids.QueryBuilder.new
      |> query(:query_string, field: :query, value: "this is a test", args: opts)
      |> getQuery
      assert expected == actual
    end

    test "when multiple queries are specified" do
      expected = %{
        bool: %{
          must: [
            %{ match: %{ search: "this is not a test" } },
            %{ query_string: %{ query: "this is a test" } }
          ]
        }
      }
      actual = Steroids.QueryBuilder.new
      |> query(:query_string, field: :query, value: "this is a test")
      |> query(:match, field: :search, value: "this is not a test")
      |> getQuery
      assert expected == actual
    end

    test "should merge nested queries" do
      expected = %{
        has_child: %{
          type: "blog_tag",
          query: %{
            term: %{ tag: "something" }
          }
        }
      }

      nested = Steroids.QueryBuilder.new
      |> query(:term, field: :tag, value: "something")

      actual = Steroids.QueryBuilder.new
      |> query(:has_child, field: :type, value: "blog_tag", nested: nested)
      |> getQuery

      assert expected == actual
    end

    test "should merge a double nested query" do
      expected = %{
        has_child: %{
          type: "blog_tag",
          query: %{
            term: %{
              tag: "something",
              query: %{
                bool: %{
                  must: [
                    %{ term: %{ tag3: "foo" } },
                    %{ term: %{ tag2: "something_else" } }
                  ]
                }
              }
            }
          }
        }
      }

      nest2 = Steroids.QueryBuilder.new
      |> query(:term, field: :tag2, value: "something_else")
      |> query(:term, field: :tag3, value: "foo")

      nested = Steroids.QueryBuilder.new
      |> query(:term, field: :tag, value: "something", nested: nest2)

      actual = Steroids.QueryBuilder.new
      |> query(:has_child, field: :type, value: "blog_tag", nested: nested)
      |> getQuery

      assert expected == actual
    end
  end
  
  describe "orQuery/3" do
    test "when multiple or queryies are specified" do
      expected = %{
        bool: %{
          should: [
            %{ match: %{ search: "this is not a test" } },
            %{ query_string: %{ query: "this is a test" } }
          ]
        }
      }
      actual = Steroids.QueryBuilder.new
      |> orQuery(:query_string, field: :query, value: "this is a test")
      |> orQuery(:match, field: :search, value: "this is not a test")
      |> getQuery

      assert expected == actual
    end

    test "should merge nested or query" do
      expected = %{
        has_child: %{
          type: "blog_tag",
          query: %{
            bool: %{
              should: [
                %{ term: %{ tag: "something else"} },
                %{ term: %{ tag: "something" } }
              ]
            }
          }
        }
      }

      nested = Steroids.QueryBuilder.new
      |> orQuery(:term, field: :tag, value: "something")
      |> orQuery(:term, field: :tag, value: "something else")

      actual = Steroids.QueryBuilder.new
      |> query(:has_child, field: :type, value: "blog_tag", nested: nested)
      |> getQuery

      assert expected == actual
    end
  end
  
  test "heterogeneous query" do
    expected = %{
      bool: %{
        must: [
          %{ match: %{ search: "this is not a test" } },
          %{ query_string: %{ query: "this is a test" } }
        ],
        should: [
          %{ match: %{ search: "this is not a test" } },
          %{ query_string: %{ query: "this is a test" } }
        ]
      }
    }
      
    actual = Steroids.QueryBuilder.new
    |> orQuery(:query_string, field: :query, value: "this is a test")
    |> orQuery(:match, field: :search, value: "this is not a test")
    |> addQuery(:query_string, field: :query, value: "this is a test")
    |> andQuery(:match, field: :search, value: "this is not a test")
    |> getQuery

    assert expected == actual
  end
end
