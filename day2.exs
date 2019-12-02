defmodule VM do
  def new(ops \\ []) do
    %{ip: 0, ops: ops}
  end

  # Halt is returned as a signal from the step function below and tells us to
  # stop running
  def run({:halt, vm}), do: Enum.at(vm.ops, 0)
  def run(vm), do: run(step(vm))

  def restore_state(vm, noun, verb) do
    ops =
      vm.ops
      |> List.replace_at(1, noun)
      |> List.replace_at(2, verb)

    %{vm | ops: ops}
  end

  def replace_at(vm, position, val) do
    %{vm | ops: List.replace_at(vm.ops, position, val)}
  end

  # Addition
  def step(vm) do
    case Enum.slice(vm.ops, vm.ip, 4) do
      # Addition
      [1, pos1, pos2, out_pos] ->
        ops = exec(vm.ops, pos1, pos2, out_pos, fn in1, in2 -> in1 + in2 end)
        %{vm | ip: vm.ip+4, ops: ops}

      # multiplication
      [2, pos1, pos2, out_pos] ->
        ops = exec(vm.ops, pos1, pos2, out_pos, fn in1, in2 -> in1 * in2 end)
        %{vm | ip: vm.ip+4, ops: ops}

      # Halt
      [99 | _rest] ->
        {:halt, vm}
    end
  end

  def exec(ops, pos1, pos2, output, f) do
    in1 = Enum.at(ops, pos1)
    in2 = Enum.at(ops, pos2)
    List.replace_at(ops, output, f.(in1, in2))
  end
end

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
