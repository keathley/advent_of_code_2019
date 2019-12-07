defmodule Day7 do
  def pt1(program) do
    vm = VM.load(program)

    phases()
    |> Task.async_stream(& try_sequence(vm, &1))
    |> Stream.map(fn {:ok, result} -> result end)
    |> Enum.max()
  end

  def pt2(program) do
    phases(5..9)
    |> Enum.map(& try_feedback(program, &1))
    |> Enum.max()
  end

  def try_feedback(prog, phases) do
    a = VM.start(prog)
    b = VM.start(prog)
    c = VM.start(prog)
    d = VM.start(prog)
    e = VM.start(prog)
    redirects = %{a => b, b => c, c => d, d => e, e => a}

    for {vm, phase} <- Enum.zip([a,b,c,d,e], phases) do
      send(vm, {:get, phase})
    end

    send(a, {:get, 0})

    direct_msgs(redirects, e)
  end

  defp direct_msgs(map, e) do
    receive do
      {:put, pid, val} ->
        send(map[pid], {:get, val})
        direct_msgs(map, e)

      {:done, ^e, val} ->
        val
    end
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
