defmodule Aoc2023.Day7 do
  @moduledoc false

  @demo """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  JJJJJ 123
  """

  @strength %{
    "2" => 1,
    "3" => 2,
    "4" => 3,
    "5" => 4,
    "6" => 5,
    "7" => 6,
    "8" => 7,
    "9" => 8,
    "T" => 9,
    "Q" => 11,
    "K" => 12,
    "A" => 13,
    # "J" => 10 # part 1
    "J" => 0 # part2
  }

  @rank_points %{
    :five_of_a_kind => 700,
    :four_of_a_kind => 600,
    :full_house => 500,
    :three_of_a_kind => 400,
    :two_pair => 300,
    :one_pair => 200,
    :high_card => 100
  }

  def part2() do
    input()
    |> Enum.map(fn [set, bet] ->

      {{set, String.to_integer(bet)}, set
      |> String.split("", trim: true)
      |> Enum.group_by(& &1)
      |> jokers_are_just_trolling(set)}
    end)
    |> apply_quantum_physics()
  end

  def part1() do
    input()
    |> Enum.map(fn [set, bet] ->

      {{set, String.to_integer(bet)}, set
      |> String.split("", trim: true)
      |> Enum.group_by(& &1)
      |> Enum.map(fn {_k, v} -> Enum.count(v) end)
      |> Enum.sort(:desc)}
    end)
    |> Enum.map(&encoder/1)
    |> apply_quantum_physics()
  end

  def apply_quantum_physics(list) do
    list
    |> Enum.map(&put_rank_score/1)
    |> Enum.map(&put_card_score/1)
    |> Enum.sort(&sort_with_rules/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {{{_card, bet}, _rank, _rank_score, _card_score}, final_rank} -> bet * final_rank end)
    |> Enum.sum()
  end

  def encoder({set, [1, 1, 1, 1, 1]}), do: {set, :high_card}
  def encoder({set, [2, 1, 1, 1]}), do: {set, :one_pair}
  def encoder({set, [2, 2, 1]}), do: {set, :two_pair}
  def encoder({set, [3, 1, 1]}), do: {set, :three_of_a_kind}
  def encoder({set, [3, 2]}), do: {set, :full_house}
  def encoder({set, [4, 1]}), do: {set, :four_of_a_kind}
  def encoder({set, [5]}), do: {set, :five_of_a_kind}
  def encoder({set, []}), do: {set, :five_of_a_kind}

  def jokers_are_just_trolling(grouped_results, set) do
    joker_count = Map.get(grouped_results, "J", []) |> Enum.count()

    # find the best card
    {k, count} = Enum.sort_by(grouped_results, fn {k, v} ->
      if k == "J", do: -1, else: Enum.count(v)
    end)
    |> List.last()

    # Add k type cards based on the amount of jokers
    # so the encoder will just see that we have count + joker_counts of k type
    new_count = Enum.reduce(1..joker_count//1, count, fn _, acc -> [k | acc] end)

    map = Map.update!( grouped_results, k, fn _ -> new_count end)
    |> Map.delete("J")
    |> Enum.map(fn {_k, v} -> Enum.count(v) end)
    |> Enum.sort(:desc)

    encoder({set, map})
    |> elem(1)
  end

  def put_rank_score({set, rank}), do: {set, rank, Map.get(@rank_points, rank)}

  def put_card_score({{set, bet}, rank, rank_score}) do
    set_score =
      set
      |> String.split("", trim: true)
      |> Enum.reduce(0, &Map.get(@strength, &1) + &2)

    {{set, bet}, rank, rank_score, set_score}
  end

  def sort_with_rules({{a_set, _}, a_rank, a_rank_score, a_card_score}, {{b_set, _}, b_rank, b_rank_score, b_card_score}) do
    if a_rank == b_rank do
      to_cmp = Enum.zip([String.split(a_set, "", trim: true), String.split(b_set, "", trim: true)])
      to_cmp = Enum.map(to_cmp, fn {a,b} -> {Map.get(@strength, a), Map.get(@strength, b)} end)

      Enum.reduce_while(to_cmp, false, fn {a, b}, acc ->
        if a == b, do: {:cont, acc}, else: {:halt, a < b}
      end)
    else
      a_rank_score + a_card_score < b_rank_score + b_card_score
    end
  end

  def input() do
    File.read!("lib/day7/input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
  end
end
