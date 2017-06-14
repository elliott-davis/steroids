defmodule Utils do
  def boolMerge([]), do: %{}
  def boolMerge(queries) when length(queries) == 1, do: elem(List.last(queries), 2)
  def boolMerge(queries) do
    Enum.reduce(queries, %{}, fn({:bool, condition, query}, acc) ->
      Map.merge(acc, %{bool: %{condition => List.wrap(query)}}, &customizer(&1, &2, &3))
    end)
  end

  defp customizer(_k, l1, l2) when is_list(l1) and is_list(l2), do: l1 ++ l2
  defp customizer(_k, l1, l2) when is_map(l1) and is_map(l2), do: Map.merge(l1, l2, &customizer(&1, &2, &3))
  defp customizer(_k, l1, _l2), do: l1
end
