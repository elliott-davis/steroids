defmodule Steroids.FilterBuilder do
  import Steroids.Utils, only: [boolMerge: 1, buildClause: 1]
  @moduledoc """
  Documentation for Filter Module.
  """

  @spec new() :: list
  def new, do: []

  @spec filter(list, atom, keyword) :: list
  def filter(filters, type, opts \\ [])
  def filter(filters, type, opts) do
    opts = mergeNested(Keyword.get(opts, :nested), opts)
    [Steroids.BoolQuery.new(:filter, type, buildClause(opts)) | filters]
  end

  defdelegate andFilter(filters, type, opts \\ []), to: Steroids.FilterBuilder, as: :filter
  defdelegate addFilter(filters, type, opts \\ []), to: Steroids.FilterBuilder, as: :filter

  @spec orFilter(list, atom, keyword) :: list
  def orFilter(filters, type, opts \\ [])
  def orFilter(filters, type, opts) do
    opts = mergeNested(Keyword.get(opts, :nested), opts)
    [Steroids.BoolQuery.new(:filter, :or, type, buildClause(opts)) | filters]
  end

  @spec notFilter(list, atom, keyword) :: list
  def notFilter(filters, type, opts \\ [])
  def notFilter(filters, type, opts) do
    opts = mergeNested(Keyword.get(opts, :nested), opts)
    [Steroids.BoolQuery.new(:filter, :not, type, buildClause(opts)) | filters]
  end

  @spec getFilter(list) :: map
  def getFilter(filters), do: boolMerge(filters)

  @doc """
  Minimum Should Match
  https://www.elastic.co/guide/en/elasticsearch/reference/current/filter-dsl-minimum-should-match.html
  """
  def filterMinimumShouldMatch([], _param), do: []
  def filterMinimumShouldMatch(filters, param) do
    should_entries = Enum.filter(filters, fn
      {:filter, _, :should, _} -> true
      _ -> false
    end)
    case length(should_entries) > 1 do
      true -> [{:minimum_should_match, :filter, param} | filters]
      false -> filters
    end
  end

  defp mergeNested(nil, opts), do: opts
  defp mergeNested(nested, opts) do
    # We need to convert these filters to queries so they are properly nested in the filter context as queries
    list = Enum.map(nested, fn({:filter, term, condition, query}) -> {:query, term, condition, query} end)
    Keyword.put(opts, :args, Map.merge(%{ filter: getFilter(list) }, Keyword.get(opts, :args, %{})))
  end
end
