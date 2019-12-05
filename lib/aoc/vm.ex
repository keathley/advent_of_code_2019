defmodule VM do
  def from_string(str) do
    ops =
      str
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    new(ops)
  end

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

  def to_instruction(ops, ip) do
    number = Enum.at(ops, ip)

    digits =
      number
      |> Integer.digits()
      |> Enum.reverse()

    opcode = digits |> Enum.take(2)
    # put opcodes back into teh correct shape
    opcode = if Enum.count(opcode) == 1, do: [0 | opcode], else: Enum.reverse(opcode)

    case opcode do
      [0, 1] ->
        {:add, input_params(ops, ip, digits, 2), Enum.at(ops, ip+3), ip+4}

      [0, 2] ->
        {:mul, input_params(ops, ip, digits, 2), Enum.at(ops, ip+3), ip+4}

      [0, 3] ->
        {:get, Enum.at(ops, ip+1), ip+2}

      [0, 4] ->
        {:put, input_params(ops, ip, digits, 1), ip+2}

      [9, 9] ->
        {:halt, []}
    end
  end

  def input_params(ops, ip, instruction, count) do
    for i <- 1..count do
      val = Enum.at(ops, ip+i)
      if Enum.at(instruction, i+1) == 1 do
        val
      else
        Enum.at(ops, val)
      end
    end
  end

  # Addition
  def step(vm) do
    case to_instruction(vm.ops, vm.ip) do
      {:add, [a, b], out, ip} ->
        ops = List.replace_at(vm.ops, out, a + b)
        %{vm | ip: ip, ops: ops}

      {:mul, [a, b], out, ip} ->
        ops = List.replace_at(vm.ops, out, a * b)
        %{vm | ip: ip, ops: ops}

      {:get, out, ip} ->
        input = IO.gets("Input: ")
                |> String.trim()
                |> String.to_integer()
        ops = List.replace_at(vm.ops, out, input)
        %{vm | ip: ip, ops: ops}

      {:put, [val], ip} ->
        IO.puts("#{val}")
        %{vm | ip: ip}

      {:halt, _} ->
        {:halt, vm}
    end
  end

  def exec(ops, pos1, pos2, output, f) do
    in1 = Enum.at(ops, pos1)
    in2 = Enum.at(ops, pos2)
    List.replace_at(ops, output, f.(in1, in2))
  end
end


