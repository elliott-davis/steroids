defmodule FilterBuilderTest do
  use ExUnit.Case
  import Steroids.FilterBuilder, only: [
    filterMinimumShouldMatch: 2,
    filter: 2, filter: 3,
    orFilter: 3, addFilter: 3, andFilter: 3,
    getFilter: 1]
  doctest Steroids.FilterBuilder

  describe "filterMinimumShouldMatch/2" do
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
      actual = Steroids.FilterBuilder.new
      |> orFilter(:term, field: :user, value: "you")
      |> orFilter(:term, field: :user, value: "me")
      |> filterMinimumShouldMatch(5)
      |> getFilter

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
      actual = Steroids.FilterBuilder.new
      |> orFilter(:term, field: :user, value: "me")
      |> filterMinimumShouldMatch(5)
      |> getFilter

      assert expected == actual
    end
  end
  describe "filter/2" do
    test "when only a type is supplied" do
      expected = %{ match_all: %{} }
      actual = Steroids.FilterBuilder.new
      |> filter(:match_all)
      |> getFilter
      assert expected == actual
    end
  end

  describe "filter/3" do
    test "when a type is supplied with a field" do
      expected = %{ match_all: %{ boost: 1.2 } }
      actual = Steroids.FilterBuilder.new
      |> filter(:match_all, field: %{ boost: 1.2 })
      |> getFilter
      assert expected == actual
    end

    test "when a type is supplied with a field and value" do
      expected = %{ match: %{ message: "this is a test" } }
      actual = Steroids.FilterBuilder.new
      |> filter(:match, field: :message, value: "this is a test")
      |> getFilter
      assert expected == actual
    end

    test "when a type is supplied with a field and map value" do
      message = %{
        filter: "this is a test",
        operator: "and"
      }
      expected = %{
        match: %{
          message: message
        }
      }
      actual = Steroids.FilterBuilder.new
      |> filter(:match, field: :message, value: message)
      |> getFilter
      assert expected == actual
    end

    test "when a type is supplied with a field, value, and args" do
      opts = %{ fields: [ "content", "name"] }
      expected = %{
        filter_string: %{
          filter: "this is a test",
          fields: [ "content", "name"]
        }
      }
      actual = Steroids.FilterBuilder.new
      |> filter(:filter_string, field: :filter, value: "this is a test", args: opts)
      |> getFilter
      assert expected == actual
    end

    test "when multiple filters are specified" do
      expected = %{
        bool: %{
          must: [
            %{ match: %{ search: "this is not a test" } },
            %{ filter_string: %{ filter: "this is a test" } }
          ]
        }
      }
      actual = Steroids.FilterBuilder.new
      |> filter(:filter_string, field: :filter, value: "this is a test")
      |> filter(:match, field: :search, value: "this is not a test")
      |> getFilter
      assert expected == actual
    end

    test "should merge nested filters" do
      expected = %{
        has_child: %{
          type: "blog_tag",
          filter: %{
            term: %{ tag: "something" }
          }
        }
      }

      nested = Steroids.FilterBuilder.new
      |> filter(:term, field: :tag, value: "something")

      actual = Steroids.FilterBuilder.new
      |> filter(:has_child, field: :type, value: "blog_tag", nested: nested)
      |> getFilter

      assert expected == actual
    end

    test "should merge a double nested filter" do
      expected = %{
        has_child: %{
          type: "blog_tag",
          filter: %{
            term: %{
              tag: "something",
              filter: %{
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

      nest2 = Steroids.FilterBuilder.new
      |> filter(:term, field: :tag2, value: "something_else")
      |> filter(:term, field: :tag3, value: "foo")

      nested = Steroids.FilterBuilder.new
      |> filter(:term, field: :tag, value: "something", nested: nest2)

      actual = Steroids.FilterBuilder.new
      |> filter(:has_child, field: :type, value: "blog_tag", nested: nested)
      |> getFilter

      assert expected == actual
    end
  end
  
  describe "orFilter/3" do
    test "when multiple or filteries are specified" do
      expected = %{
        bool: %{
          should: [
            %{ match: %{ search: "this is not a test" } },
            %{ filter_string: %{ filter: "this is a test" } }
          ]
        }
      }
      actual = Steroids.FilterBuilder.new
      |> orFilter(:filter_string, field: :filter, value: "this is a test")
      |> orFilter(:match, field: :search, value: "this is not a test")
      |> getFilter

      assert expected == actual
    end

    test "should merge nested or filter" do
      expected = %{
        has_child: %{
          type: "blog_tag",
          filter: %{
            bool: %{
              should: [
                %{ term: %{ tag: "something else"} },
                %{ term: %{ tag: "something" } }
              ]
            }
          }
        }
      }

      nested = Steroids.FilterBuilder.new
      |> orFilter(:term, field: :tag, value: "something")
      |> orFilter(:term, field: :tag, value: "something else")

      actual = Steroids.FilterBuilder.new
      |> filter(:has_child, field: :type, value: "blog_tag", nested: nested)
      |> getFilter

      assert expected == actual
    end
  end
  
  test "heterogeneous filter" do
    expected = %{
      bool: %{
        must: [
          %{ match: %{ search: "this is not a test" } },
          %{ filter_string: %{ filter: "this is a test" } }
        ],
        should: [
          %{ match: %{ search: "this is not a test" } },
          %{ filter_string: %{ filter: "this is a test" } }
        ]
      }
    }
      
    actual = Steroids.FilterBuilder.new
    |> orFilter(:filter_string, field: :filter, value: "this is a test")
    |> orFilter(:match, field: :search, value: "this is not a test")
    |> addFilter(:filter_string, field: :filter, value: "this is a test")
    |> andFilter(:match, field: :search, value: "this is not a test")
    |> getFilter

    assert expected == actual
  end
end
