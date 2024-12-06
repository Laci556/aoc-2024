import adglent.{type Example, Example}
import day1/solve
import gleam/list
import gleeunit/should

type Problem1AnswerType =
  Int

type Problem2AnswerType =
  Int

const part1_examples: List(Example(Problem1AnswerType)) = [
  Example(
    "3   4
4   3
2   5
1   3
3   9
3   3",
    11,
  ),
]

const part2_examples: List(Example(Problem2AnswerType)) = [
  Example(
    "3   4
4   3
2   5
1   3
3   9
3   3",
    31,
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
