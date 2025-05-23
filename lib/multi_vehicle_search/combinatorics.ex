defmodule MultiVehicleSearch.Combinatorics do
  def combinations(list, size) do
    list
    |> Enum.to_list()
    |> combinations(size, [])
  end

  defp combinations(_, 0, acc), do: [acc]
  defp combinations([], _, _), do: []

  defp combinations([head | tail], size, acc) do
    combinations(tail, size - 1, [head | acc]) ++
      combinations(tail, size, acc)
  end
end
