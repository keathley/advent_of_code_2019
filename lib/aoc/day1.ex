defmodule DayOne do
  # part 1
  def fuel(mass) do
    div(mass, 3) - 2
  end

  # part 2
  def fuel_fuel(mass, fuel \\ 0)
  def fuel_fuel(mass, fuel) do
    new_fuel = div(mass, 3) - 2

    if new_fuel <= 0 do
      fuel
    else
      fuel_fuel(new_fuel, fuel + new_fuel)
    end
  end
end

# input = """
#
# """

# input =
#   String.split()
#   |> Enum.map(&String.to_integer/1)
#   |> Enum.map(&DayOne.fuel_fuel/1)
#   |> Enum.sum()
#   |> IO.puts
