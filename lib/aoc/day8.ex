defmodule Day8 do
  # Image encoder / decoder
  @width 25
  @height 6

  def pt1(input) do
    layers = decode(input)

    layer = Enum.min_by(layers, fn l -> Enum.count(l, & &1 == 0) end)

    Enum.count(layer, & &1 == 1) * Enum.count(layer, & &1 == 2)
  end

  def pt2(input, width \\ @width, height \\ @height) do
    layers = decode(input, width, height)
    image = stack(layers, width, height)
    rows = Enum.chunk_every(image, width)
    Enum.each(rows, fn r ->
      Enum.each(r, fn c ->
        case c do
          0 -> IO.write(IO.ANSI.white_background() <> " ")
          1 -> IO.write(IO.ANSI.black_background() <> "*")
        end
      end)
      IO.write(IO.ANSI.black_background() <> "\n")
    end)
  end

  def stack(ls, width \\ @width, height \\ @height) do
    initial = for i <- 0..(width * height)-1,
      do: {i, []},
      into: %{}

    layer_map =
      ls
      |> Enum.reverse
      |> Enum.reduce(initial, fn l, map ->
        l
        |> Enum.with_index
        |> Enum.reduce(map, fn {e, i}, acc ->
          Map.put(acc, i, [e | acc[i]])
        end)
      end)

    layer_map
    |> Enum.sort_by(fn {i, _} -> i end)
    |> Enum.map(fn {i, pixels} -> Enum.find(pixels, & &1 != 2) end)
  end

  def decode(input, width \\ @width, height \\ @height) do
    digits =
      input
      |> String.replace("\n", "")
      |> String.trim()
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)

    layers =
      digits
      |> Enum.chunk_every(width*height)
  end
end
