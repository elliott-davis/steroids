defmodule Steroids.Utils do
  @spec boolMerge(list) :: map
  def boolMerge([]), do: %{}
  # If we are a single bool should we need to include the condition
  def boolMerge([{_type, field, :should, query}]), do:
    %{ bool: %{ should: List.wrap(%{ field => query }) } }
  def boolMerge([{_type, field, :must_not, query}]), do:
    %{ bool: %{ must_not: List.wrap(%{ field => query }) } }
  def boolMerge(queries) when length(queries) == 1 do
    item = List.last(queries)
    %{ elem(item, 1) => elem(item, 3) }
  end
  def boolMerge(queries) do
    Enum.reduce(queries, %{}, fn
      ({:query, field, condition, query}, acc) ->
        Map.merge(acc, %{bool: %{condition => List.wrap(%{ field => query})}}, &customizer(&1, &2, &3))
      ({:filter, field, condition, query}, acc) ->
        Map.merge(acc, %{bool: %{ filter: %{ bool: %{ condition => List.wrap(%{ field => query})}}}}, &customizer(&1, &2, &3))
      ({:minimum_should_match, :filter, count}, acc) ->
        Map.merge(acc, %{bool: %{ filter: %{ bool: %{ minimum_should_match: count } } } })
      ({:minimum_should_match, :query, count}, acc) ->
        Map.merge(acc, %{bool: %{ minimum_should_match: count } })
    end)
  end

  @spec buildClause(list) :: map
  def buildClause(opts \\ []) do
    buildClause(Keyword.get(opts, :field, %{}), Keyword.get(opts, :value), Keyword.get(opts, :args, %{}))
  end

  defp buildClause(%{} = field, nil, opts), do: Map.merge(field, opts)
  defp buildClause(field, nil, opts), do: Map.merge(%{field: field }, opts)
  defp buildClause(field, value, opts), do: Map.merge(%{field => value}, opts)

  defp customizer(_k, l1, l2) when is_list(l1) and is_list(l2), do: l1 ++ l2
  defp customizer(_k, l1, l2) when is_map(l1) and is_map(l2), do: Map.merge(l1, l2, &customizer(&1, &2, &3))
  defp customizer(_k, l1, _l2), do: l1
end
