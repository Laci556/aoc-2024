import adglent.{First, Second}
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

fn parse_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [sum, values] = string.split(line, ": ")
    let assert Ok(sum) = int.parse(sum)
    let values =
      values |> string.split(" ") |> list.map(int.parse) |> result.values
    #(sum, values)
  })
}

fn check_equation_inner(
  sum: Int,
  values: List(Int),
  results: Set(Int),
  concat: Bool,
) {
  case values {
    [x, ..xs] ->
      check_equation_inner(
        sum,
        xs,
        set.fold(results, set.new(), fn(acc, y) {
          let acc =
            acc
            |> set.insert(x + y)
            |> set.insert(x * y)
          use <- bool.guard(!concat, acc)
          acc
          |> set.insert(result.unwrap(
            {
              let assert Ok(x) = int.digits(x, 10)
              let assert Ok(y) = int.digits(y, 10)
              int.undigits(list.flatten([y, x]), 10)
            },
            0,
          ))
        }),
        concat,
      )
    _ -> results |> set.contains(sum)
  }
}

fn check_equation(sum: Int, values: List(Int), concat: Bool) {
  let assert [x, ..xs] = values
  check_equation_inner(sum, xs, set.from_list([x]), concat)
}

pub fn part1(input: String) {
  input
  |> parse_input
  |> list.fold(0, fn(acc, x) {
    let #(sum, values) = x
    case check_equation(sum, values, False) {
      True -> acc + sum
      False -> acc
    }
  })
}

pub fn part2(input: String) {
  input
  |> parse_input
  |> list.fold(0, fn(acc, x) {
    let #(sum, values) = x
    case check_equation(sum, values, True) {
      True -> acc + sum
      False -> acc
    }
  })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("7")
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
