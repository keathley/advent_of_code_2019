defmodule OrbitMap do
  def from_string(str) do
    str
    |> String.split()
    |> Enum.map(& String.split(&1, ")"))
    |> build()
  end

  def build(inputs) do
    g = :digraph.new()

    for [v1, v2] <- inputs do
      :digraph.add_vertex(g, v1)
      :digraph.add_vertex(g, v2)
      :digraph.add_edge(g, v1, v2)
      :digraph.add_edge(g, v2, v1)
    end

    g
  end

  def path(g, v1, v2) do
    Enum.count(:digraph.get_short_path(g, v1, v2)) - 3
  end

  def total_orbits(g) do
    [top | _] = :digraph_utils.topsort(g)

    g
    |> :digraph_utils.postorder()
    |> Enum.map(fn v -> :digraph.get_path(g, top, v) end)
    |> Enum.filter(&is_list/1)
    |> Enum.map(& Enum.count(&1) - 1)
    |> Enum.sum()
  end
end
