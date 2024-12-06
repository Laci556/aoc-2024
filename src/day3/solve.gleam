import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}

pub fn part1(input: String) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(re, input)
  |> list.fold(0, fn(acc, match) {
    let assert Match(_, [Some(a), Some(b)]) = match
    let assert Ok(a) = int.parse(a)
    let assert Ok(b) = int.parse(b)
    acc + a * b
  })
}

pub fn part2(input: String) {
  let assert Ok(re) =
    regexp.from_string("(mul)\\((\\d+),(\\d+)\\)|(do)\\(\\)|(don't)\\(\\)")
  let #(sum, _) =
    regexp.scan(re, input)
    |> list.fold(#(0, True), fn(acc, match) {
      case match {
        Match(_, [Some("mul"), Some(a), Some(b)]) if acc.1 -> {
          let assert Ok(a) = int.parse(a)
          let assert Ok(b) = int.parse(b)
          #(acc.0 + a * b, acc.1)
        }
        Match(_, [_, _, _, Some("do")]) -> {
          #(acc.0, True)
        }
        Match(_, [_, _, _, _, Some("don't")]) -> {
          #(acc.0, False)
        }
        _ -> acc
      }
    })
  sum
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("3")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}
