defmodule OrbitMap do
  def from_string(str) do
    str
    |> String.split()
    |> Enum.map(& String.split(&1, ")"))
    |> build()
  end

  def build(inputs) do
    Enum.reduce(inputs, %{}, fn [v1, v2], g ->
      g
      |> Map.update(v1, [v2], & [v2 | &1])
      |> Map.update(v2, [v1], & [v1 | &1])
    end)
  end

  # BFS to find to create the shortest path tree
  def distance(g, v1, v2) do
    Map.get(bfs(g, v1), v2)
  end

  def bfs(g, source) do
    dists = for {vertex, _} <- g,
      do: {vertex, :infinity},
      into: %{}

    dists = Map.put(dists, source, 0)

    q = :queue.new()
    q = :queue.in(source, q)

    bfs(g, q, dists)
  end

  defp bfs(g, q, dists) do
    if :queue.is_empty(q) do
      dists
    else
      {{:value, u}, q} = :queue.out(q)
      {dists, q} = Enum.reduce(neighbors(g, u), {dists, q}, fn v, {d, q} ->
        if dists[v] == :infinity do
          q = :queue.in(v, q)
          d = Map.put(d, v, d[u] + 1)
          {d, q}
        else
          {d, q}
        end
      end)

      bfs(g, q, dists)
    end
  end

  defp neighbors(g, u) do
    Map.get(g, u)
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
