defmodule Aoc2023.Day2 do
  @moduledoc false

  @demo """
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  """

  def part2() do
    Enum.reduce(parser(), 0, fn {_k, v}, acc ->
      v
      |> Map.values()
      |> Enum.product()
      |> Kernel.+(acc)
    end)
  end

  def part1() do
    bounds = %{"red" => 12, "green" => 13, "blue" => 14}

    Enum.filter(parser(), fn {_k, v} ->
      bounds
      |> Enum.map(fn {color, total} -> v[color] <= total end)
      |> Enum.all?()
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def parser() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      ["Game " <> game_id, rounds] =  String.split(line, ":", trim: true)

      rounds
      |> String.split(";")
      |> Enum.map(fn round ->
        round
        |> String.split(",", trim: true)
        |> Enum.reduce(%{}, fn draws, acc ->
          [count, color] =
            draws
            |> String.trim()
            |> String.split(" ")

          Map.put(acc, color, String.to_integer(count))
        end)
      end)
      |> Enum.reduce(%{}, fn round, acc ->
        Map.merge(acc, round, fn _k, v1, v2 ->
            if v1 > v2, do: v1, else: v2
        end)
      end)
      |> then(&Map.put(acc, String.to_integer(game_id), &1))
    end)
  end

  def input() do
    File.read!("lib/day2/input.txt")
  end
end
