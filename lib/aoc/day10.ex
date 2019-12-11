defmodule Day10 do
  def pt1(str) do
    as = get_asteroids(str)
    views = find_visible(as)
    find_best(views)
  end

  def pt2(str) do
    as = get_asteroids(str)
    all_views = find_visible(as)
    {point, _} = find_best(all_views)
    views = Map.get(all_views, point)

    # We now have the references for all other asteroids from our central point
    # We can group them by angle, sort the internal points by magnitude and sort
    # by angle and we should be able to solve by counting up to 200.
    views
    |> Enum.group_by(fn {_, _, angle, _} -> angle end)
    |> Enum.map(fn {angle, points} -> {angle, Enum.sort_by(points, fn {_, _, _, mag} -> mag end)} end)
    |> fire_da_layza()
  end

  def fire_da_layza(asteroids) do
    angles =
      asteroids
      |> Enum.map(fn {a, _} -> a end)
      |> Enum.sort()

    fire(angles, Enum.into(asteroids, %{}), -1, 1)
  end

  defp fire([new_angle | angles], asteroids, angle, count) do
    [point | points] = Map.get(asteroids, new_angle)

    if count == 200 do
      point
    else
      if points == [] do
        new_asteroids = Map.delete(asteroids, new_angle)
        fire(angles, new_asteroids, new_angle, count+1)
      else
        new_asteroids = Map.put(asteroids, new_angle, points)
        fire(angles ++ [new_angle], new_asteroids, new_angle, count+1)
      end
    end
  end

  def find_best(views) do
    views
    |> Enum.map(fn {k, others} ->
      uniqs =
        others
        |> Enum.uniq_by(fn {_, _, angle, _mag} -> angle end)
      {k, uniqs}
    end)
    |> Enum.max_by(fn {_, uniqs} -> Enum.count(uniqs) end)
  end

  def find_visible(as) do
    as
    |> Enum.map(fn a -> {a, calculate_angles(a, as)} end)
    |> Enum.into(%{})
  end

  def calculate_angles({x1, y1}, as) do
    as
    |> Enum.reject(fn {x2, y2} -> x1 == x2 && y1 == y2 end)
    |> Enum.map(fn {x2, y2} -> {x2-x1, y2-y1} end)
    |> Enum.map(fn {x, y} ->
      angle =
        cond do
          x == 0 -> if y > 0, do: 180, else: 0
          y == 0 -> if x > 0, do: 90, else: 270
          true ->
            rads = :math.atan(abs(y)/abs(x))
            degrees = rads * (180/:math.pi)

            # The degrees are all fucked here because of how we draw the
            # origins but its consistent so fuckit
            cond do
              x > 0 and y > 0 -> degrees + 90
              x < 0 and y > 0 -> degrees + 180
              x < 0 and y < 0 -> degrees + 270
              true ->
                degrees
            end
        end

      mag = :math.sqrt(:math.pow(x, 2) + :math.pow(y, 2))

      {x+x1, y+y1, angle, mag}
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
