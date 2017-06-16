 defmodule QueryBuilder do
  @moduledoc """
  Documentation for Query Module.
  """

  def new do
    []
  end

  def query(queries, type), do: [BoolQuery.new(type, %{}) | queries]
  def query(queries, type, field), do: [BoolQuery.new(type, Utils.buildClause(field, nil)) | queries]
  def query(queries, type, field, value), do: [BoolQuery.new(type, Utils.buildClause(field, value)) | queries]
  def query(queries, type, field, value, args), do: [BoolQuery.new(type, Utils.buildClause(field, value, args)) | queries]

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

  def getQuery(queries), do: Utils.boolMerge(queries)

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