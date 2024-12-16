import adglent.{type Example, Example}
import day10/solve
import gleam/list
import gleeunit/should

type Problem1AnswerType =
  Int

type Problem2AnswerType =
  Int

const part1_examples: List(Example(Problem1AnswerType)) = [
  Example(
    "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732",
    36,
  ),
]

const part2_examples: List(Example(Problem2AnswerType)) = [
  Example(
    "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732",
    81,
  ),
]

pub fn part1_test() {
  part1_examples
  |> should.not_equal([])
  use example <- list.map(part1_examples)
  solve.part1(example.input)
  |> should.equal(example.answer)
}

pub fn part2_test() {
  part2_examples
  |> should.not_equal([])
  use example <- list.map(part2_examples)
  solve.part2(example.input)
  |> should.equal(example.answer)
}
