defmodule AoCTest do
  use ExUnit.Case
  doctest AoC

  test "greets the world" do
    assert AoC.hello() == :world
  end
end
