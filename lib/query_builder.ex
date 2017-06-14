 defmodule QueryBuilder do
  @moduledoc """
  Documentation for Query Module.
  """

  def new do
    %{}
  end

  def query(queryBuilder, _args) do
    makeQuery(queryBuilder, :and)
  end

  # Alias for query
  def andQuery(queryBuilder, args) do
    query(queryBuilder, args)
  end

  # Alias for query
  def addQuery(queryBuilder, args) do
    query(queryBuilder, args)
  end

  def orQuery(queryBuilder, args) do
    makeQuery(queryBuilder, :or, args)
  end

  def notQuery(queryBuilder, args) do
    makeQuery(queryBuilder, :not, args)
  end

  def queryMinimumShouldMatch(queryBuilder, param) do
    addMinimumShouldMatch(queryBuilder, param)
  end

  #   @doc """
  # Minimum Should Match
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-minimum-should-match.html
  # """
  defp addMinimumShouldMatch(%{bool: %{should: values}} = queryBuilder, param) when length(values) > 1 do
    put_in(queryBuilder, [:bool, :minimum_should_match], param)
  end
  defp addMinimumShouldMatch(queryBuilder, _param) do
    queryBuilder
  end

  defp makeQuery(queryBuilder, _boolType) do
    queryBuilder
  end
  defp makeQuery(queryBuilder, _boolType, _queryType) do
    queryBuilder
  end
end
