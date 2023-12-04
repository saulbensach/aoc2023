defmodule Aoc2023.Day4 do
  @moduledoc false

  @demo """
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
  """

  # 2 - [3, 4]
  # 2 - [3, 4]

  # 3- [4,5]
  # 3- [4,5]
  # 3- [4,5]
  # 3- [4,5]

  # 1 - 1
  # 2 - 1 | 2 |
  # 3 - 1 | 3 | 4
  # 4 - 1 | 3 | 7
  # 5 - 1 | 1 | 5

  # 1 - 4
  # 2 - 2
  # 3 - 2

  def part2() do
    cards = input()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      ["Card " <> id, rest] = String.split(line, ":", trim: true)
      id = String.trim(id)

      [winning, draws] =
        rest
        |> String.trim()
        |> String.split("|")

      winning = String.trim(winning) |> String.split(" ", trim: true)
      draws = String.trim(draws) |> String.split(" ", trim: true)

      {String.to_integer(id), winning, draws}
    end)

    Enum.reduce(cards, %{}, fn {id, winning, draws}, acc ->
      hits = Enum.map(winning, & &1 in draws)
      |> Enum.filter(& &1)
      |> Enum.count()

      {current, acc} = Map.get_and_update(acc, id, fn count ->
        count = (if count, do: count, else: 0) + 1
        {count, count}
      end)

      Enum.reduce(1..hits//1, acc, fn hit, acc ->
        Map.update(acc, id + hit, current, fn counter -> counter + current end)
      end)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def part1() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      ["Card " <> id, rest] = String.split(line, ":", trim: true)

      [winning, draws] =
        rest
        |> String.trim()
        |> String.split("|")

      winning = String.trim(winning) |> String.split(" ", trim: true)
      draws = String.trim(draws) |> String.split(" ", trim: true)

      hits = Enum.map(winning, & &1 in draws)
      |> Enum.filter(& &1)

      cond do
        Enum.count(hits) == 0 ->
          0

        Enum.count(hits) == 1 ->
          1

        true ->
         count = Enum.count(hits) - 1
         points = for _ <- 1..count, do: 2
         Enum.product([1] ++ points)
      end
    end)
    |> Enum.sum
  end

  def input() do
    File.read!("lib/day4/input.txt")
  end
end
