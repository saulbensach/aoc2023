defmodule Aoc2023.Day3 do
  @moduledoc false

  @demo """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  ...290*891
  """

  @matrix_bounds 140

  def part1() do
    matrix = build_matrix()
    parsed_matrix = parse_matrix()

    Enum.reduce(parsed_matrix, [], fn {index, {_id, _value}} = item, acc ->
      if Enum.any?(neighbours(index), &not is_nil(matrix[&1])), do: [item | acc], else: acc
    end)
    |> Enum.uniq_by(fn {_, {id, _}} -> id end)
    |> Enum.map(fn {_, {_, value}} -> String.to_integer(value) end)
    |> Enum.sum()
  end

  def part2() do
    matrix =
      build_matrix()
      |> Enum.filter(fn {_index, value} -> value == "*" end)
      |> Enum.into(%{})

    parsed_matrix = parse_matrix()

    Enum.reduce(matrix, 0, fn {index, _}, acc ->
      matches = Enum.reduce(neighbours(index), [], fn n_index, acc ->
        if is_nil(parsed_matrix[n_index]), do: acc, else: [parsed_matrix[n_index] | acc]
      end)
      |> Enum.uniq_by(fn {id, _} -> id end)
      |> Enum.map(fn {_, value} -> String.to_integer(value) end)

      if Enum.count(matches) == 2, do: Enum.product(matches) + acc, else: acc
    end)
  end

  def parse_matrix() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.with_index(fn row, index ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index(&{{index,&2}, &1})
      # MEGA hack in order to have a terminator LMAOO
      |> then(& &1++["."])
      |> Enum.reduce({[], []}, fn
        ".", {acc, final_acc} ->
          digit = parse_digit({index, String.length(row) - 1}, acc)
          [digit |final_acc]

        # why ~c"1" in ?0..?9 does not WORK!!!
        {_char_index, char}, {acc, final_acc} when char in ["0", "1", "2", "3", "4", "5", "6" ,"7", "8", "9"] ->
          {[char |acc], final_acc}

        {_char_index, "."}, {[], final_acc} ->
          {[], final_acc}


        {char_index, "."}, {acc, final_acc} ->
          digit = parse_digit(char_index, acc)

          {[], [digit |final_acc]}

        {_char_index, char}, {[], final_acc} when char in ["*", "=", "@", "+", "&", "-", "/", "#", "%", "$"] ->
          {[], final_acc}

        {char_index, char}, {acc, final_acc} when char in ["*", "=", "@", "+", "&", "-", "/", "#", "%", "$"] ->
          digit = parse_digit(char_index, acc)

          {[], [digit | final_acc]}

        _, acc ->
          acc
      end)
    end)
    |> List.flatten()
    |> Enum.reduce(%{}, &Map.merge(&2, &1))
  end

  def parse_digit({x, y}, acc) do
    digit = acc |> Enum.reverse() |> Enum.join("")
    digit_length = String.length(digit)
    id = :rand.bytes(5)
    for offset <- 1..digit_length, into: %{}, do: {{x, y - offset}, {id, digit}}
  end

  def build_matrix() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.with_index(fn row, index ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index(&{{index, &2}, &1})
      |> Enum.reject(fn {_, item} -> item == "." end)
      |> Enum.reject(fn {_, item} -> item in ["0", "1", "2", "3", "4", "5", "6" ,"7", "8", "9"] end)
      |> Enum.into(%{})
    end)
    |> Enum.reduce(%{}, &Map.merge(&2, &1))
  end

  def neighbours({x, y}) do
    for i <- -1..1, j <- -1..1, do: {x + i, y + j}
  end

  def input() do
    File.read!("lib/day3/input.txt")
  end
end
