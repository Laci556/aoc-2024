import adglent.{First, Second}
import gleam/bool
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

type Facing {
  North
  East
  South
  West
}

type Guard {
  Guard(pos: #(Int, Int), facing: Facing)
}

fn rotate(facing: Facing) {
  case facing {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

fn get_new_pos(guard: Guard) {
  let Guard(pos, facing) = guard
  case facing {
    North -> #(pos.0 - 1, pos.1)
    East -> #(pos.0, pos.1 + 1)
    South -> #(pos.0 + 1, pos.1)
    West -> #(pos.0, pos.1 - 1)
  }
}

fn count_unique_steps_inner(
  rows: Int,
  cols: Int,
  obstacles: Set(#(Int, Int)),
  guard: Guard,
  visited: Set(#(Int, Int)),
) {
  let new_pos = get_new_pos(guard)
  let visited = set.insert(visited, guard.pos)

  use <- bool.guard(
    new_pos.0 < 0 || new_pos.0 >= rows || new_pos.1 < 0 || new_pos.1 >= cols,
    visited |> set.size,
  )

  count_unique_steps_inner(
    rows,
    cols,
    obstacles,
    case set.contains(obstacles, new_pos) {
      True -> Guard(..guard, facing: rotate(guard.facing))
      _ -> Guard(..guard, pos: new_pos)
    },
    visited,
  )
}

fn count_unique_steps(
  rows: Int,
  cols: Int,
  obstacles: Set(#(Int, Int)),
  guard: Guard,
) {
  count_unique_steps_inner(rows, cols, obstacles, guard, set.new())
}

fn parse_input(input: String) {
  let rows =
    input
    |> string.split("\n")

  let row_count = list.length(rows)
  let col_count = {
    let assert [x, ..] = rows
    string.length(x)
  }

  let assert #(obstacles, Some(guard)) =
    rows
    |> list.index_fold(#(set.new(), None), fn(acc, line, i) {
      line
      |> string.split("")
      |> list.index_fold(acc, fn(acc, char, j) {
        let #(obstacles, start) = acc
        case char {
          "#" -> #(set.insert(obstacles, #(i, j)), start)
          "^" -> #(obstacles, Some(Guard(#(i, j), North)))
          ">" -> #(obstacles, Some(Guard(#(i, j), East)))
          "v" -> #(obstacles, Some(Guard(#(i, j), South)))
          "<" -> #(obstacles, Some(Guard(#(i, j), West)))
          _ -> acc
        }
      })
    })

  #(row_count, col_count, obstacles, guard)
}

pub fn part1(input: String) {
  let #(row_count, col_count, obstacles, guard) = parse_input(input)

  count_unique_steps(row_count, col_count, obstacles, guard)
}

fn check_loop(
  rows: Int,
  cols: Int,
  obstacles: Set(#(Int, Int)),
  guard: Guard,
  visited: Set(Guard),
) {
  use <- bool.guard(set.contains(visited, guard), True)
  let new_pos = get_new_pos(guard)

  use <- bool.guard(
    new_pos.0 < 0 || new_pos.0 >= rows || new_pos.1 < 0 || new_pos.1 >= cols,
    False,
  )

  check_loop(
    rows,
    cols,
    obstacles,
    case set.contains(obstacles, new_pos) {
      True -> Guard(..guard, facing: rotate(guard.facing))
      _ -> Guard(..guard, pos: new_pos)
    },
    set.insert(visited, guard),
  )
}

fn count_loops_inner(
  rows: Int,
  cols: Int,
  obstacles: Set(#(Int, Int)),
  guard: Guard,
  visited: Set(Guard),
  loops: Int,
) {
  let visited = set.insert(visited, guard)
  let new_pos = get_new_pos(guard)

  use <- bool.guard(
    new_pos.0 < 0 || new_pos.0 >= rows || new_pos.1 < 0 || new_pos.1 >= cols,
    loops,
  )

  let is_obstacle = set.contains(obstacles, new_pos)

  let loops = case
    !is_obstacle
    && !list.any([North, East, South, West], fn(facing) {
      visited |> set.contains(Guard(new_pos, facing))
    })
    && check_loop(
      rows,
      cols,
      set.insert(obstacles, new_pos),
      Guard(..guard, facing: rotate(guard.facing)),
      visited,
    )
  {
    False -> loops
    True -> loops + 1
  }

  count_loops_inner(
    rows,
    cols,
    obstacles,
    case is_obstacle {
      True -> Guard(..guard, facing: rotate(guard.facing))
      False -> Guard(..guard, pos: new_pos)
    },
    visited,
    loops,
  )
}

fn count_loops(rows: Int, cols: Int, obstacles: Set(#(Int, Int)), guard: Guard) {
  count_loops_inner(rows, cols, obstacles, guard, set.new(), 0)
}

pub fn part2(input: String) {
  let #(row_count, col_count, obstacles, guard) = parse_input(input)

  count_loops(row_count, col_count, obstacles, guard)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("6")
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
