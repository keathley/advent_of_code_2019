defmodule Day4 do
  def valid?(num) when is_number(num) do
    num
    |> Integer.digits()
    |> valid?()
  end

  def valid?([a,b,c,d,e,f]) do
    a <= b && b <= c && c <= d && d <= e && e <= f &&
     ((a == b && b != c) ||
      (a != b && b == c && c != d) ||
      (b != c && c == d && d != e) ||
      (c != d && d == e && d != f) ||
      (d != e && e == f))
  end
end

# iex> c "day4.exs"
# iex> s = 246515
# 246515
# iex> e = 739105
# 739105
# iex> (s..e) |> Stream.filter(&Day4.valid?/1) |> Enum.count()

