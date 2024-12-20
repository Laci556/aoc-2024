import adglent.{First, Second}
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp.{Match}
import gleam/string

fn parse_input(input: String) {
  let assert Ok(re) = regexp.from_string("\\+(\\d+)|=(\\d+)")
  use machine <- list.map(input |> string.split("\n\n"))
  let assert [xa, ya, xb, yb, x, y] =
    re
    |> regexp.scan(machine)
    |> list.map(fn(match) {
      let n = case match {
        Match(_, [None, Some(n)]) -> n
        Match(_, [Some(n)]) -> n
        _ -> "0"
      }
      let assert Ok(n) = n |> int.parse
      n
    })
  #(xa, ya, xb, yb, x, y)
}

pub fn part1(input: String) {
  parse_input(input)
  |> list.fold(0, fn(acc, machine) {
    let #(xa, ya, xb, yb, x, y) = machine
    let b_numerator = ya * x - xa * y
    let b_denominator = ya * xb - yb * xa
    use <- bool.guard(b_numerator % b_denominator != 0, acc)
    let b = b_numerator / b_denominator
    use <- bool.guard(b < 0, acc)
    let a_numerator = x - xb * b
    use <- bool.guard(a_numerator % xa != 0, acc)
    let a = a_numerator / xa
    acc + 3 * a + b
  })
}

pub fn part2(input: String) {
  parse_input(input)
  |> list.fold(0, fn(acc, machine) {
    let #(xa, ya, xb, yb, x, y) = machine
    let b_numerator = ya * x - xa * y + { ya - xa } * 10_000_000_000_000
    let b_denominator = ya * xb - yb * xa
    use <- bool.guard(b_numerator % b_denominator != 0, acc)
    let b = b_numerator / b_denominator
    use <- bool.guard(b < 0, acc)
    let a_numerator = x + 10_000_000_000_000 - xb * b
    use <- bool.guard(a_numerator % xa != 0, acc)
    let a = a_numerator / xa
    acc + 3 * a + b
  })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("13")
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
