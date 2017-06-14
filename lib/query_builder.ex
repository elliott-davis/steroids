 defmodule QueryBuilder do
  @moduledoc """
  Documentation for Query Module.
  """

  # def new do
  #   %{}
  # end

  # def query(querybuilder, args) do
  #   makeQuery(querybuilder, :and)
  # end

  # # Alias for query
  # def andQuery(queryBuilder, args) do
  #   query(queryBuilder, args)
  # end

  # # Alias for query
  # def addQuery(queryBuilder, args) do
  #   query(queryBuilder, args)
  # end

  # def orQuery(queryBuilder, args) do
  #   makeQuery(queryBuilder, :or, args)
  # end

  # def notQuery(queryBuilder, args) do
  #   makeQuery(queryBuilder, :not, args)
  # end

  # def queryMinimumShouldMatch(querybuilder, param) do
  #   addMinimumShouldMatch(querybuilder, param)
  # end

  #   @doc """
  # Minimum Should Match
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-minimum-should-match.html
  # """
  # defp addMinimumShouldMatch(%{bool: %{should: values}} = querybuilder, param) where length(values) > 1 do
  #   put_in(querybuilder["bool"]["minimum_should_match"], param)
  # end

  # defp addMinimumShouldMatch(querybuilder, _param) do
  #   querybuilder
  # end

  # defp makeQuery(queryBuilder, boolType, queryType, _args) do
  #   queryBuilder
  # end
end
