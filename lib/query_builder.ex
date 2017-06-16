 defmodule Steroids.QueryBuilder do
  import Steroids.Utils, only: [boolMerge: 1, buildClause: 1]
  @moduledoc """
  Documentation for Query Module.
  """
  @spec new() :: list
  def new, do: []

  @spec query(list, atom, keyword) :: list
  def query(queries, type, opts \\ [])
  def query(queries, type, opts), do: [Steroids.BoolQuery.new(type, buildClause(opts)) | queries]

  # # Alias for query
  # def andQuery(queries, args) do
  #   query(queryBuilder, args)
  # end

  # # Alias for query
  # def addQuery(queries, args) do
  #   query(queryBuilder, args)
  # end

  # def orQuery(queries, args) do
  #   makeQuery(queries, :or, args)
  # end

  # def notQuery(queries, args) do
  #   makeQuery(queries, :not, args)
  # end

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
