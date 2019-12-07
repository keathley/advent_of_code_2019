defmodule Day6Test do
  use ExUnit.Case, async: true

  test "test input" do
    input = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    K)YOU
    I)SAN
    """

    assert g = OrbitMap.from_string(input)
    assert OrbitMap.distance(g, "YOU", "SAN") == 6
  end
end
