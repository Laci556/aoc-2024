import adglent.{First, Second}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

pub fn part1(input: String) {
  let #(first, second) =
    input
    |> string.split("\n")
    |> list.fold(#([], []), fn(acc, line) {
      let assert [first, second] =
        line
        |> string.split("   ")
        |> list.map(int.parse)
        |> result.values

      #([first, ..acc.0], [second, ..acc.1])
    })

  list.zip(
    list.sort(first, by: int.compare),
    list.sort(second, by: int.compare),
  )
  |> list.fold(0, fn(acc, current) {
    acc + int.absolute_value(current.0 - current.1)
  })
}

pub fn part2(input: String) {
  let #(first, second) =
    input
    |> string.split("\n")
    |> list.fold(#([], dict.new()), fn(acc, line) {
      let assert [first, second] =
        line
        |> string.split("   ")
        |> list.map(int.parse)
        |> result.values

      #(
        [first, ..acc.0],
        dict.upsert(acc.1, second, fn(x) {
          case x {
            Some(i) -> i + 1
            None -> 1
          }
        }),
      )
    })

  first
  |> list.fold(0, fn(acc, current) {
    acc + current * result.unwrap(dict.get(second, current), 0)
  })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("1")
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
