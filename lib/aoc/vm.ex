defmodule VM do
  def load(str) do
    ops =
      str
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    new(ops)
  end

  def new(ops \\ []) do
    %{ip: 0, ops: ops, parent: self(), inputs: [], outputs: []}
  end

  def start(str) do
    vm = load(str)
    spawn(fn -> run(vm) end)
  end

  def run(vm, inputs) do
    run(%{vm | inputs: inputs})
  end

  # Halt is returned as a signal from the step function below and tells us to
  # stop running
  def run({:halt, %{outputs: [out|_rest]}=vm}) do
    send(vm.parent, {:done, self(), out})
  end
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

      [0, 5] ->
        {:jmpit, input_params(ops, ip, digits, 2), ip+3}

      [0, 6] ->
        {:jmpif, input_params(ops, ip, digits, 2), ip+3}

      [0, 7] ->
        {:lt, input_params(ops, ip, digits, 2), Enum.at(ops, ip+3), ip+4}

      [0, 8] ->
        {:eq, input_params(ops, ip, digits, 2), Enum.at(ops, ip+3), ip+4}

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
        # [input | rest] = vm.inputs
        receive do
          {:get, input} ->
            ops = List.replace_at(vm.ops, out, input)
            %{vm | ip: ip, ops: ops}
        end

      {:put, [val], ip} ->
        send(vm.parent, {:put, self(), val})
        %{vm | ip: ip, outputs: [val | vm.outputs]}

      {:jmpit, [a, b], ip} ->
        ip = if a != 0, do: b, else: ip
        %{vm | ip: ip}

      {:jmpif, [a, b], ip} ->
        ip = if a == 0, do: b, else: ip
        %{vm | ip: ip}

      {:lt, [a, b], out, ip} ->
        ops = List.replace_at(vm.ops, out, (if a < b, do: 1, else: 0))
        %{vm | ip: ip, ops: ops}

      {:eq, [a, b], out, ip} ->
        ops = List.replace_at(vm.ops, out, (if a == b, do: 1, else: 0))
        %{vm | ip: ip, ops: ops}

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


