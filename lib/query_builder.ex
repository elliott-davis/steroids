 defmodule Steroids.QueryBuilder do
  import Steroids.Utils, only: [boolMerge: 1, buildClause: 1]
  @moduledoc """
  Documentation for Query Module.
  """

  @spec new() :: list
  def new, do: []

  @spec query(list, atom, keyword) :: list
  def query(queries, type, opts \\ [])
  def query(queries, type, opts) do
    opts = mergeNested(Keyword.get(opts, :nested), opts)
    [Steroids.BoolQuery.new(:query, type, buildClause(opts)) | queries]
  end

  defdelegate andQuery(queries, type, opts \\ []), to: Steroids.QueryBuilder, as: :query
  defdelegate addQuery(queries, type, opts \\ []), to: Steroids.QueryBuilder, as: :query

  @spec orQuery(list, atom, keyword) :: list
  def orQuery(queries, type, opts \\ [])
  def orQuery(queries, type, opts) do
    opts = mergeNested(Keyword.get(opts, :nested), opts)
    [Steroids.BoolQuery.new(:query, :or, type, buildClause(opts)) | queries]
  end

  @spec notQuery(list, atom, keyword) :: list
  def notQuery(queries, type, opts \\ [])
  def notQuery(queries, type, opts) do
    opts = mergeNested(Keyword.get(opts, :nested), opts)
    [Steroids.BoolQuery.new(:query, :not, type, buildClause(opts)) | queries]
  end

  @spec getQuery(list) :: map
  def getQuery(queries), do: boolMerge(queries)

  @doc """
  Minimum Should Match
  https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-minimum-should-match.html
  """
  def queryMinimumShouldMatch([], _param), do: []
  def queryMinimumShouldMatch(queries, param) do
    should_entries = Enum.filter(queries, fn
      {:query, _, :should, _} -> true
      _ -> false
    end)
    IO.inspect should_entries
    case length(should_entries) > 1 do
      true -> [{:minimum_should_match, :query, param} | queries]
      false -> queries
    end
  end

  defp mergeNested(nil, opts), do: opts
  defp mergeNested(nested, opts), do:
    Keyword.put(opts, :args, Map.merge(%{ query: getQuery(nested) }, Keyword.get(opts, :args, %{})))
end
