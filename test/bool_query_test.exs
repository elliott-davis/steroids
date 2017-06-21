defmodule BoolQueryTest do
  use ExUnit.Case
  doctest Steroids.BoolQuery

  test "or condition returns should" do
    query = %{term: %{user: "foo"} }
    expected = {:filter, :term, :should, query }
    actual = Steroids.BoolQuery.new(:filter, :or, :term, query)
    assert actual == expected
  end
  
  test "invalid bool types are converted to :must" do
    query = %{term: %{user: "foo"} }
    expected = {:query, :term, :must, query}
    actual = Steroids.BoolQuery.new(:query, :invalid, :term, query)
    assert actual == expected
  end

  test "when no bool type specified :must is used" do
    query = %{term: %{user: "foo"} }
    expected = {:query, :term, :must, query}
    actual = Steroids.BoolQuery.new(:query, :term, query)
    assert actual == expected
  end
end
