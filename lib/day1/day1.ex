defmodule Aoc2023.Day1 do
  @moduledoc false

  def part1() do
    Regex.replace(~r/([A-Za-z])+/, input(), "")
    |> String.split("\n", trim: true)
    |> Enum.map(fn item -> String.first(item) <> String.last(item) end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def part2() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn line, acc ->
      Regex.scan(~r/(?=(\d|one|two|three|four|five|six|seven|eight|nine))/, line, capture: :all_but_first)
      |> List.flatten()
      |> Enum.map(&parse_to_number/1)
      |> then(fn item -> List.first(item) <> List.last(item) end)
      |> String.to_integer()
      |> then(& &1 + acc)
    end)
  end

  def parse_to_number("one"), do: "1"
  def parse_to_number("two"), do: "2"
  def parse_to_number("three"), do: "3"
  def parse_to_number("four"), do: "4"
  def parse_to_number("five"), do: "5"
  def parse_to_number("six"), do: "6"
  def parse_to_number("seven"), do: "7"
  def parse_to_number("eight"), do: "8"
  def parse_to_number("nine"), do: "9"
  def parse_to_number(value), do: value

  def input() do
    File.read!("lib/day1/input.txt")
  end
end
