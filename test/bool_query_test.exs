defmodule BoolQueryTest do
  use ExUnit.Case
  doctest Steroids.BoolQuery

  test "or condition returns should" do
    query = %{term: %{user: "foo"} }
    expected = {:bool, :term, :should, query }
    actual = Steroids.BoolQuery.new(:or, :term, query)
    assert actual == expected
  end
  
  test "invalid bool types are converted to :must" do
    query = %{term: %{user: "foo"} }
    expected = {:bool, :term, :must, query}
    actual = Steroids.BoolQuery.new(:invalid, :term, query)
    assert actual == expected
  end

  test "when no bool type specified :must is used" do
    query = %{term: %{user: "foo"} }
    expected = {:bool, :term, :must, query}
    actual = Steroids.BoolQuery.new(:term, query)
    assert actual == expected
  end
end
