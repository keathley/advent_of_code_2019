defmodule VM do
  def load(str) do
    ops =
      str
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    new(ops)
  end

  def new(ops \\ []) do
    extra_mem = for _i <- 0..4096, do: 0
    %{ip: 0, ops: ops ++ extra_mem, parent: self(), inputs: [], outputs: [], relative_base: 0}
  end

  def start(vm) do
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

  def to_instruction(%{ops: ops, ip: ip}=vm) do
    number = Enum.at(ops, ip)

    digits =
      number
      |> Integer.digits()
      |> Enum.reverse()

    opcode = digits |> Enum.take(2)
    opcode = if Enum.count(opcode) == 1, do: [0 | opcode], else: Enum.reverse(opcode)

    case opcode do
      [0, 1] ->
        out = if 2 == Enum.at(digits, 4) do
          Enum.at(vm.ops, vm.ip+3) + vm.relative_base
        else
          Enum.at(vm.ops, vm.ip+3)
        end
        {:add, input_params(vm, digits, 2), out, ip+4}

      [0, 2] ->
        out = if 2 == Enum.at(digits, 4) do
          Enum.at(vm.ops, vm.ip+3) + vm.relative_base
        else
          Enum.at(vm.ops, vm.ip+3)
        end
        {:mul, input_params(vm, digits, 2), out, ip+4}

      [0, 3] ->
        out = if 2 == Enum.at(digits, 2) do
          Enum.at(vm.ops, vm.ip+1) + vm.relative_base
        else
          Enum.at(vm.ops, vm.ip+1)
        end
        {:get, out, ip+2}

      [0, 4] ->
        {:put, input_params(vm, digits, 1), ip+2}

      [0, 5] ->
        {:jmpit, input_params(vm, digits, 2), ip+3}

      [0, 6] ->
        {:jmpif, input_params(vm, digits, 2), ip+3}

      [0, 7] ->
        out = if 2 == Enum.at(digits, 4) do
          Enum.at(vm.ops, vm.ip+3) + vm.relative_base
        else
          Enum.at(vm.ops, vm.ip+3)
        end
        {:lt, input_params(vm, digits, 2), out, ip+4}

      [0, 8] ->
        out = if 2 == Enum.at(digits, 4) do
          Enum.at(vm.ops, vm.ip+3) + vm.relative_base
        else
          Enum.at(vm.ops, vm.ip+3)
        end
        {:eq, input_params(vm, digits, 2), out, ip+4}

      [0, 9] ->
        {:move_base, input_params(vm, digits, 1), ip+2}

      [9, 9] ->
        {:halt, []}
    end
  end

  def input_params(vm, instruction, count) do
    for i <- 1..count do
      val = Enum.at(vm.ops, vm.ip+i)
      mode = Enum.at(instruction, i+1)

      cond do
        mode == 2 ->
          offset = vm.relative_base + val
          if offset < 0 do
            raise ArgumentError, "memory position cannot be negative"
          end
          Enum.at(vm.ops, offset)
        mode == 1 ->
          val
        true ->
          if val < 0 do
            raise ArgumentError, "memory position cannot be negative"
          end
          Enum.at(vm.ops, val)
      end
    end
  end

  def output_params(vm, instruction, count) do
  end

  # Addition
  def step(vm) do
    case to_instruction(vm) do
      {:add, [a, b], out, ip} ->
        ops = List.replace_at(vm.ops, out, a + b)
        %{vm | ip: ip, ops: ops}

      {:mul, [a, b], out, ip} ->
        ops = List.replace_at(vm.ops, out, a * b)
        %{vm | ip: ip, ops: ops}

      {:get, out, ip} ->
        # input = IO.gets("input:")
        #         |> String.trim()
        #         |> String.to_integer()
        # [input | rest] = vm.inputs
        send(vm.parent, {:gets, self()})
        receive do
          {:ack, input} ->
            ops = List.replace_at(vm.ops, out, input)
            %{vm | ip: ip, ops: ops}
        end
        # end

      {:put, [val], ip} ->
        send(vm.parent, {:puts, self(), val})
        # IO.puts(val)
        # send(vm.parent, {:put, self(), val})
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

      {:move_base, [val], ip} ->
        %{vm | relative_base: vm.relative_base + val, ip: ip}

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


