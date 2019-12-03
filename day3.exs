defmodule Day3 do
  @origin {0, 0}

  defmodule Point do
    def new({x, y}), do: new(x, y)
    def new(x, y) do
      %{x: x, y: y}
    end

    def manhattan_distance(p1, p2) do
      abs(p1.x - p2.x) + abs(p1.y - p2.y)
    end
  end

  def solve_p1(input) do
    [wire1, wire2] =
      input
      |> String.split()
      |> Enum.map(&parse/1)

    find_intersections(wire1, wire2)
    |> Enum.map(& elem(&1, 0))
    |> Enum.map(& {&1, Point.manhattan_distance(Point.new(@origin), &1)})
    |> Enum.min_by(fn {_, dist} -> dist end)
    |> elem(1)
  end

  def solve_p2(input) do
    [wire1, wire2] =
      input
      |> String.split()
      |> Enum.map(&parse/1)

    find_intersections(wire1, wire2)
    |> Enum.map(fn {p, s1, s2} ->
      count_steps(wire1, p, s1, 0) + count_steps(wire2, p, s2, 0)
    end)
    |> Enum.min
  end

  def count_steps([], _point, _goal, count), do: count
  def count_steps([segment | rest], point, goal, count) do
    if segment == goal do
      {start, _} = segment
      Point.manhattan_distance(start, point) + count
    else
      count_steps(rest, point, goal, count + segment_distance(segment))
    end
  end

  def segment_distance({p1, p2}), do: Point.manhattan_distance(p1, p2)

  def parse(str) do
    path =
      str
      |> String.split(",")
      |> Enum.map(&string_to_vector/1)
      |> Enum.scan(@origin, fn {ax, ay}, {bx, by} -> {bx + ax, by + ay} end)
      |> Enum.map(&Point.new/1)

    to_segments([Point.new(@origin) | path], [])
  end

  def to_segments([], acc), do: Enum.reverse(acc)
  def to_segments([p1, p2], acc), do: to_segments([], [{p1, p2} | acc])
  def to_segments([p1, p2 | rest], acc) do
    to_segments([p2 | rest], [{p1, p2} | acc])
  end

  def find_intersections(wire1, wire2) do
    wire1
    |> Enum.flat_map(& find_intersecting_segments(&1, wire2))
  end

  def find_intersecting_segments(segment, path2) do
    path2
    |> Enum.filter(& intersect?(segment, &1))
    |> Enum.map(fn {p1, p2}=s2 ->
      if p1.x == p2.x do
        {Point.new(p1.x, elem(segment, 0).y), segment, s2}
      else
        {Point.new(elem(segment, 0).x, p1.y), segment, s2}
      end
    end)
  end

  def intersect?(seg1, seg2) do
    f = fn {ap1, ap2}, {bp1, bp2} ->
      ap1.y == ap2.y &&
      bp1.x == bp2.x &&
      min(ap1.x, ap2.x) < bp1.x and bp1.x < max(ap1.x, ap2.x) &&
      min(bp1.y, bp2.y) < ap1.y and ap1.y < max(bp1.y, bp2.y)
    end

    f.(seg1, seg2) || f.(seg2, seg1)
  end

  # Convert to vectors which are easily applied to a point
  def string_to_vector(<<direction :: binary-size(1), magnitude :: binary>>) do
    magnitude = String.to_integer(magnitude)

    case direction do
      "R" -> {magnitude, 0}
      "L" -> {-1*magnitude, 0}
      "U" -> {0, magnitude}
      "D" -> {0, -1*magnitude}
    end
  end
end
