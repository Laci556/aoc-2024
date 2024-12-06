import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

fn parse_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.values
  })
}

pub fn part1(input: String) {
  input
  |> parse_input
  |> list.fold(0, fn(acc, line) {
    case check_level(line) {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn part2(input: String) {
  input
  |> parse_input
  |> list.fold(0, fn(acc, line) {
    let safe =
      check_level(line)
      || {
        list.combinations(line, list.length(line) - 1)
        |> list.any(check_level)
      }

    case safe {
      True -> acc + 1
      False -> acc
    }
  })
}

fn check_level_inner(level: List(Int), min_diff: Int, max_diff: Int) {
  case level {
    [x, y, ..] if y - x < min_diff || y - x > max_diff -> False
    [_, y, ..ys] -> check_level_inner([y, ..ys], min_diff, max_diff)
    _ -> True
  }
}

fn check_level(level: List(Int)) {
  case level {
    [a, b, ..] if a != b -> {
      let #(min_diff, max_diff) = case a < b {
        True -> #(1, 3)
        False -> #(-3, -1)
      }
      check_level_inner(level, min_diff, max_diff)
    }
    _ -> False
  }
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("2")
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
