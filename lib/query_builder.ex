 defmodule Steroids.QueryBuilder do
  import Steroids.Utils, only: [boolMerge: 1, buildClause: 1]
  @moduledoc """
  Documentation for Query Module.
  """
  
  @spec new() :: list
  def new, do: []

  @spec query(list, atom, keyword) :: list
  def query(queries, type, opts \\ [])
  def query(queries, type, opts), do:
    [Steroids.BoolQuery.new(type, buildClause(opts)) | queries]

  # Alias for query
  @spec andQuery(list, atom, keyword) :: list
  def andQuery(queries, type, opts \\ []), do: query(queries, type, opts)

  # Alias for query
  @spec addQuery(list, atom, keyword) :: list
  def addQuery(queries, type, opts \\ []), do: query(queries, type, opts)

  @spec orQuery(list, atom, keyword) :: list
  def orQuery(queries, type, opts \\ [])
  def orQuery(queries, type, opts), do:
    [Steroids.BoolQuery.new(:or, type, buildClause(opts)) | queries]

  @spec notQuery(list, atom, keyword) :: list
  def notQuery(queries, type, opts \\ [])
  def notQuery(queries, type, opts), do:
    [Steroids.BoolQuery.new(:not, type, buildClause(opts)) | queries]

  @spec getQuery(list) :: map
  def getQuery(queries), do: boolMerge(queries)

  @doc """
  Minimum Should Match
  https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-minimum-should-match.html
  """
  def queryMinimumShouldMatch(queryBuilder, param) do
    addMinimumShouldMatch(queryBuilder, param)
  end

  defp addMinimumShouldMatch(%{bool: %{should: values}} = queryBuilder, param) when length(values) > 1 do
    put_in(queryBuilder, [:bool, :minimum_should_match], param)
  end
  defp addMinimumShouldMatch(queryBuilder, _param) do
    queryBuilder
  end
end
