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
    [Steroids.BoolQuery.new(type, buildClause(opts)) | filters]
  end
  # Alias for filter
  @spec andFilter(list, atom, keyword) :: list
  def andFilter(filters, type, opts \\ []), do: filter(filters, type, opts)

  # Alias for filter
  @spec addFilter(list, atom, keyword) :: list
  def addFilter(filters, type, opts \\ []), do: filter(filters, type, opts)

  @spec orFilter(list, atom, keyword) :: list
  def orFilter(filters, type, opts \\ [])
  def orFilter(filters, type, opts) do
    opts = mergeNested(Keyword.get(opts, :nested), opts)
    [Steroids.BoolQuery.new(:or, type, buildClause(opts)) | filters]
  end

  @spec notFilter(list, atom, keyword) :: list
  def notFilter(filters, type, opts \\ [])
  def notFilter(filters, type, opts) do
    opts = mergeNested(Keyword.get(opts, :nested), opts)
    [Steroids.BoolQuery.new(:not, type, buildClause(opts)) | filters]
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
      {:bool, _, :should, _} -> true
      _ -> false
    end)
    case length(should_entries) > 1 do
      true -> [{:minimum_should_match, param} | filters]
      false -> filters
    end
  end

  defp mergeNested(nil, opts), do: opts
  defp mergeNested(nested, opts), do:
    Keyword.put(opts, :args, Map.merge(%{ filter: getFilter(nested) }, Keyword.get(opts, :args, %{})))
end
