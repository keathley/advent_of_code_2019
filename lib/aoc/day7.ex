defmodule Day7 do
  def pt1(program) do
    vm = VM.load(program)
    # vm = VM.start(program)

    phases()
    |> Task.async_stream(& try_sequence(vm, &1))
    |> Stream.map(fn {:ok, result} -> result end)
    |> Enum.max()
  end

  def pt2(program) do
    phases(5..9)
    |> Enum.map(& try_feedback(program, &1))
  end

  def try_feedback(prog, phases) do
    a = VM.load(prog)
    b = VM.load(prog)
    c = VM.load(prog)
    d = VM.load(prog)
    e = VM.load(prog)

    # Enum.reduce(phases,
  end

  def phases(range \\ 0..4) do
    all =
      for a <- range,
          b <- range,
          c <- range,
          d <- range,
          e <- range,
        do: [a, b, c, d, e]

    Stream.filter(all, & Enum.uniq(&1) == &1)
  end

  def try_sequence(vm, phases) do
    [out] = Enum.reduce(phases, [0], fn phase, prev ->
      VM.run(vm, [phase | prev])
    end)

    out
  end
end
