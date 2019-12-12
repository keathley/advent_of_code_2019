defmodule Robot do
  def new(program) do
    brain = VM.load(program) |> VM.start()

    %{brain: brain, panels: %{{0, 0} => 1}, direction: :up, position: {0, 0}, paint_jobs: MapSet.new()}
  end

  def run(robot) do
    receive do
      {:done, _, _} ->
        robot

      {:gets, brain} ->
        send(brain, {:ack, current_panel(robot)})
        robot
        |> paint_panel(get_output())
        |> turn_direction(get_output())
        |> move_forward()
        |> run()
    end
  end

  def print_result(robot) do
    xmax = 42
    ymax = 5

    for y <- 0..ymax do
      for x <- 0..xmax do
        color = robot.panels[{x, y}] || 0
        case color do
          0 -> IO.write IO.ANSI.black_background() <> " "
          1 -> IO.write IO.ANSI.white_background() <> "*"
        end
      end
      IO.write IO.ANSI.black_background <> "\n"
    end
  end

  defp get_output() do
    receive do
      {:puts, _brain, val} -> val
    end
  end

  defp current_panel(robot) do
    robot.panels[robot.position] || 0
  end

  defp paint_panel(robot, color) do
    %{robot | panels: Map.put(robot.panels, robot.position, color), paint_jobs: MapSet.put(robot.paint_jobs, robot.position)}
  end

  defp turn_direction(robot, direction) do
    %{robot | direction: new_direction(robot.direction, direction)}
  end

  defp move_forward(%{position: {x, y}}=robot) do
    new_pos = case robot.direction do
      :up    -> {x, y-1}
      :down  -> {x, y+1}
      :right -> {x+1, y}
      :left  -> {x-1, y}
    end

    %{robot | position: new_pos}
  end

  defp new_direction(:up, 0), do: :left
  defp new_direction(:left, 0), do: :down
  defp new_direction(:down, 0), do: :right
  defp new_direction(:right, 0), do: :up
  defp new_direction(:up, 1), do: :right
  defp new_direction(:right, 1), do: :down
  defp new_direction(:down, 1), do: :left
  defp new_direction(:left, 1), do: :up
end

defmodule Day11 do
  def pt1 do

  end
end
