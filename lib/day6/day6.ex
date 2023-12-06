defmodule Aoc2023.Day6 do
  @moduledoc false

  @demo %{
    7 => 9,
    15 => 40,
    30 => 200
  }

  @input %{
    46 => 358,
    68 => 1054,
    98 => 1807,
    66 => 1080
  }

  def part2() do
    generator({46689866, 358105418071080})
  end

  def part1() do
    @input
    |> Enum.map(&generator(&1))
    |> Enum.product()
  end

  def generator({race_time, record}) do
    Enum.reduce(0..race_time, 0, &Kernel.if(&1*(race_time-&1) > record, do: &2+1, else: &2))
  end
end
