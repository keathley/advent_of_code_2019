defmodule Day10 do
  def pt1(str) do
    as = get_asteroids(str)
    views = find_visible(as)

    {k, _} =
      views
      |> Enum.max_by(fn {_, c} -> c end)

    k
  end

  def find_visible(as) do
    as
    |> Enum.map(fn a -> {a, Enum.count(Enum.uniq(calculate_angles(a, as)))} end)
    |> Enum.into(%{})
    |> IO.inspect(label: "Values")
  end

  def calculate_angles({x1, y1}, as) do
    as
    |> Enum.reject(fn {x2, y2} -> x1 == x2 && y1 == y2 end)
    |> Enum.map(fn {x2, y2} -> {x2-x1, y2-y1} end)
    |> Enum.map(fn {x, y} ->
      cond do
        x == 0 -> if y > 0, do: 180, else: 0
        y == 0 -> if x > 0, do: 90, else: 270
        true -> :math.atan(y/x)
      end
    end)
  end

  def get_asteroids(str) do
    str
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {e, x} -> if e == "#", do: {x, y} end)
    end)
    |> Enum.reject(fn e -> e == nil end)
  end
end
