defmodule Steroids.BoolQuery do
  @valid_conditions [:must, :must_not, :should]

  @spec new(atom, map) :: {:bool, atom, atom, map}
  def new(field, clause), do: {:bool, field, cond_atom(:and), clause}
  def new(condition, field, clause), do: {:bool, field, cond_atom(condition), clause}

  defp cond_atom(:mustNot), do: :must_not
  defp cond_atom(:and), do: :must
  defp cond_atom(:or), do: :should
  defp cond_atom(:not), do: :must_not
  defp cond_atom(val) when val in @valid_conditions, do: val
  defp cond_atom(_), do: :must
end
