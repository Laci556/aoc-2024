import adglent.{First, Second}
import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string

fn parse_input(input: String) {
  let lines = input |> string.split("\n")
  let rows = lines |> list.length
  let cols = {
    let assert [x, ..] = lines
    x |> string.length
  }

  let antennas = {
    use acc, line, i <- list.index_fold(lines, dict.new())
    use acc, char, j <- list.index_fold(line |> string.split(""), acc)

    case char {
      "." -> acc
      freq ->
        acc
        |> dict.upsert(freq, fn(x) {
          let new_antenna = #(i, j)
          case x {
            Some(x) -> x |> set.insert(new_antenna)
            None -> set.from_list([new_antenna])
          }
        })
    }
  }

  #(antennas, rows, cols)
}

pub fn part1(input: String) {
  let #(antennas, rows, cols) = input |> parse_input

  let antinodes = {
    use acc, _, antennas <- dict.fold(antennas, set.new())
    let combinations = antennas |> set.to_list |> list.combination_pairs
    use acc, #(a, b) <- list.fold(combinations, acc)

    let antinodes = [
      #(2 * a.0 - b.0, 2 * a.1 - b.1),
      #(2 * b.0 - a.0, 2 * b.1 - a.1),
    ]

    antinodes
    |> list.fold(acc, fn(acc, antinode) {
      case antinode {
        #(row, col) if row >= 0 && row < rows && col >= 0 && col < cols ->
          acc |> set.insert(antinode)
        _ -> acc
      }
    })
  }

  antinodes |> set.size
}

fn generate_steps(
  nodes: List(#(Int, Int)),
  offset: #(Int, Int),
  rows: Int,
  cols: Int,
) {
  let assert [pos, ..] = nodes
  case pos.0 + offset.0, pos.1 + offset.1 {
    r, c if r >= 0 && r < rows && c >= 0 && c < cols ->
      generate_steps([#(r, c), ..nodes], offset, rows, cols)
    _, _ -> nodes
  }
}

fn generate_antinodes(a: #(Int, Int), b: #(Int, Int), rows: Int, cols: Int) {
  generate_steps([a], #(a.0 - b.0, a.1 - b.1), rows, cols)
  |> set.from_list
  |> set.union(
    generate_steps([b], #(b.0 - a.0, b.1 - a.1), rows, cols) |> set.from_list,
  )
}

pub fn part2(input: String) {
  let #(antennas, rows, cols) = input |> parse_input

  let antinodes = {
    use acc, _, antennas <- dict.fold(antennas, set.new())
    let combinations = antennas |> set.to_list |> list.combination_pairs
    use acc, #(a, b) <- list.fold(combinations, acc)

    generate_antinodes(a, b, rows, cols) |> set.union(acc)
  }

  antinodes |> set.size
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("8")
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
