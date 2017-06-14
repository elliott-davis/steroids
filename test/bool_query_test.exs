defmodule BoolQueryTest do
  use ExUnit.Case
  doctest BoolQuery

  test "or condition returns should" do
    query = %{term: %{user: "foo"} }
    expected = {:bool, :should, query }
    actual = BoolQuery.new(:or, query)
    assert actual == expected
  end
  
  test "invalid bool types are converted to :must" do
    query = %{term: %{user: "foo"} }
    expected = {:bool, :must, query}
    actual = BoolQuery.new(:invalid, query)
    assert actual == expected
  end

  test "when no bool type specified :must is used" do
    query = %{term: %{user: "foo"} }
    expected = {:bool, :must, query}
    actual = BoolQuery.new(query)
    assert actual == expected
  end
end
