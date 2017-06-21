defmodule Steroids do
  @moduledoc """
  Documentation for Steroids.
  """

  def new, do: []

  # TODO: impl array sort
  def sort(body, field, direction \\ "asc"), do:
    Map.merge(body, %{ sort: [ %{ field => %{ order: direction } } ] })

  def from(body, quantity), do: Map.merge(body, %{ from: quantity })

  def size(body, quantity), do: Map.merge(body, %{ size: quantity })

  def rawOption(body, key, value), do: Map.merge(body, %{ key => value})

  def build(items) do
    res = Enum.group_by(items, &elem(&1, 0))
    |> Enum.map(fn({k,v}) -> { k, Steroids.Utils.boolMerge(v) } end)
    build(Keyword.get(res, :query), Keyword.get(res, :filter))
  end

  defp build(nil, nil), do: %{}
  defp build(nil, %{} = filter), do: %{ query: %{ bool: %{ filter: filter}}}
  defp build(%{ bool: _values } = query, filter) do
    Map.merge(filter(filter), %{query: query }, &deep_merge(&1, &2, &3))
  end
  defp build(query, filter) do
    Map.merge(filter(filter), query(query), &deep_merge(&1, &2, &3))
  end

  defp filter(filter), do: %{ query: %{ bool: %{ filter: filter}}}
  defp query(query), do: %{ query: %{ bool: %{ must: query }}}

  defp deep_merge(_k, l1, l2) when is_map(l1) and is_map(l2), do: Map.merge(l1, l2, &deep_merge(&1, &2, &3))
  defp deep_merge(_k, l1, _l2), do: l1
end
