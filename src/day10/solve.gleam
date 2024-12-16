import adglent.{First, Second}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import gleam/yielder.{Done, Next}
import tote/bag

fn parse_input(input: String) {
  input
  |> string.split("\n")
  |> list.index_fold(#(dict.new(), set.new()), fn(acc, line, row) {
    line
    |> string.to_graphemes
    |> list.index_fold(acc, fn(acc, char, col) {
      let #(positions, starts) = acc
      let assert Ok(n) = char |> int.parse
      #(positions |> dict.insert(#(row, col), n), case n == 0 {
        True -> starts |> set.insert(#(row, col))
        _ -> starts
      })
    })
  })
}

fn trail_score_rating(trailhead: #(Int, Int), positions: Dict(#(Int, Int), Int)) {
  let visited =
    #(bag.from_list([trailhead]), bag.new())
    |> yielder.unfold(fn(acc) {
      use <- bool.guard(acc.0 |> bag.is_empty(), Done)

      let #(to_visit, visited) =
        acc.0
        |> bag.fold(#(bag.new(), acc.1), fn(acc, x, copies) {
          let #(to_visit, visited) = acc
          let visited = visited |> bag.insert(copies, x)
          let assert Ok(height) = positions |> dict.get(x)

          use <- bool.guard(height == 9, #(to_visit, visited))

          #(
            to_visit
              |> bag.merge(
                [#(-1, 0), #(1, 0), #(0, -1), #(0, 1)]
                |> list.fold(bag.new(), fn(to_visit, offset) {
                  let dest = #(x.0 + offset.0, x.1 + offset.1)
                  case positions |> dict.get(dest) {
                    Ok(dest_height) if height + 1 == dest_height -> {
                      use <- bool.guard(visited |> bag.contains(dest), to_visit)
                      to_visit |> bag.insert(copies, dest)
                    }
                    _ -> to_visit
                  }
                }),
              ),
            visited,
          )
        })

      Next(element: visited, accumulator: #(to_visit, visited))
    })
    |> yielder.last()

  case visited {
    Ok(visited) ->
      visited
      |> bag.fold(#(0, 0), fn(acc, x, copies) {
        case positions |> dict.get(x) {
          Ok(9) -> #(acc.0 + 1, acc.1 + copies)
          _ -> acc
        }
      })
    _ -> #(0, 0)
  }
}

pub fn part1(input: String) {
  let #(positions, starts) = input |> parse_input
  starts
  |> set.fold(0, fn(acc, start) { acc + trail_score_rating(start, positions).0 })
}

pub fn part2(input: String) {
  let #(positions, starts) = input |> parse_input
  starts
  |> set.fold(0, fn(acc, start) { acc + trail_score_rating(start, positions).1 })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("10")
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
