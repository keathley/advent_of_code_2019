defmodule Day2 do
  def p1(input) do
    input
    |> parse()
    |> VM.new()
    |> VM.restore_state(12, 2)
    |> VM.run
  end

  # part 2
  def p2(input) do
    vm =
      input
      |> parse
      |> VM.new()

    permutations = for i <- 0..99, j <- 0..99, do: {i, j}

    # Generate all possible permutations of the vm as a lazy stream. Find the
    # one that generates the correct output.
    {{noun, verb}, _} =
      permutations
      |> Stream.map(fn {i, j} -> {{i, j}, VM.restore_state(vm, i, j)} end)
      |> Stream.map(fn {perm, vm} -> {perm, VM.run(vm)} end)
      |> Enum.find(fn {perm, out} -> out == 19690720 end)

    100 * noun + verb
  end

  def parse(input) do
    input
    |> String.split
    |> Enum.flat_map(& String.split(&1, ","))
    |> Enum.map(&String.to_integer/1)
  end
end
