defmodule Aoc2023.Day5 do
  @moduledoc false

  @demo """
  seeds: 79 14 55 13

  seed-to-soil map:
  50 98 2
  52 50 48

  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15

  fertilizer-to-water map:
  49 53 8
  0 11 42
  42 0 7
  57 7 4

  water-to-light map:
  88 18 7
  18 25 70

  light-to-temperature map:
  45 77 23
  81 45 19
  68 64 13

  temperature-to-humidity map:
  0 69 1
  1 0 69

  humidity-to-location map:
  60 56 37
  56 93 4
  """

  # Idea is to run this, clean the house, walk the dog, walk myself, go on an small trip
  # and dont think for 5 hours how to intersect range sets
  def part2() do
    data = parse()
    {seeds, data} = Map.pop(data, "seeds")
    data = Enum.map(data, fn {a, {b, list}} ->
      list = Enum.sort_by(list, fn {_, _..b} -> b end)

      {a, {b, list}}
    end)

    Enum.chunk_every(seeds, 2)
    |> Task.async_stream(fn [a, b] ->
      Stream.map(a..(a+b), fn seed ->
        Enum.reduce(data, seed, fn {_, {_, list}}, acc ->
          if Enum.any?(list, fn {_dest_range, source_range} -> acc in source_range end) do
            {start_dest.._, start_source.._} = Enum.find(list, fn {_dest_range, source_range} ->
              acc in source_range
            end)

            acc - start_source + start_dest
          else
            acc
          end
        end)
      end)
      |> Enum.min()
      |> IO.inspect
    end, timeout: :infinity)
    |> Enum.min_by(&elem(&1, 1))
  end

  def part1() do
    data = parse()
    {seeds, data} = Map.pop(data, "seeds")

    Enum.map(seeds, fn seed ->
      Enum.reduce(data, seed, fn {_, {_, list}}, acc ->
        if Enum.any?(list, fn {_dest_range, source_range} -> acc in source_range end) do
          {start_dest.._, start_source.._} = Enum.find(list, fn {_dest_range, source_range} ->
            acc in source_range
          end)

          acc - start_source + start_dest
        else
          acc
        end
      end)
    end)
    |> Enum.min()
  end

  def parse() do
    input()
    |> String.split("\n")
    |> Enum.chunk_by(& &1 == "")
    |> Enum.reduce({[], 0}, fn
      [""], acc ->
        acc
      list, {acc, index} ->
        {[parse_map_block(list, index) | acc], index + 1}
    end)
    |> elem(0)
    |> Enum.reverse()
    |> Enum.into(%{})
  end

  def parse_map_block(["seeds: " <> seeds], _index) do
    seeds =
      seeds
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    {"seeds", seeds}
  end

  def parse_map_block([head | list], index) do
    [name, numbers] = String.split(head, " ", trim: true)
    bounds =
      list
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> Enum.map(fn [a, b, length] ->
        parse_ranges({a, b, length})
      end)

    {index, {name, bounds}}
  end

  def parse_ranges({dest_range_start, source_range_start, length}) do
    {bound_parser(dest_range_start, length), bound_parser(source_range_start, length)}
  end

  def bound_parser(string, length) do
    char = String.to_integer(string)
    length = String.to_integer(length)

    char..((char + length) - 1)
  end

  def input() do
    @demo
    File.read!("lib/day5/input.txt")
  end
end
