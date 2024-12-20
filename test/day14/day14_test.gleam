import adglent.{type Example, Example}
import day14/solve
import gleam/list
import gleeunit/should

type Problem1AnswerType =
  Int

const part1_examples: List(Example(Problem1AnswerType)) = [
  Example(
    "p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3",
    12,
  ),
]

pub fn part1_test() {
  part1_examples
  |> should.not_equal([])
  use example <- list.map(part1_examples)
  solve.part1(example.input, 11, 7)
  |> should.equal(example.answer)
}
