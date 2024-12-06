import adglent.{First, Second}
import gleam/dict
import gleam/io
import gleam/list
import gleam/string

pub fn part1(input: String) {
  let lines = input |> string.split("\n")
  let chars =
    lines
    |> list.index_fold(dict.new(), fn(acc, line, i) {
      string.to_graphemes(line)
      |> list.index_fold(acc, fn(acc, char, j) {
        acc |> dict.insert(#(i, j), char)
      })
    })

  let starts = chars |> dict.filter(fn(_, value) { value == "X" })

  starts
  |> dict.fold(0, fn(sum, pos, _) {
    let #(i, j) = pos
    let word_positions = [
      #(#(i + 1, j), #(i + 2, j), #(i + 3, j)),
      #(#(i - 1, j), #(i - 2, j), #(i - 3, j)),
      #(#(i, j + 1), #(i, j + 2), #(i, j + 3)),
      #(#(i, j - 1), #(i, j - 2), #(i, j - 3)),
      #(#(i + 1, j + 1), #(i + 2, j + 2), #(i + 3, j + 3)),
      #(#(i - 1, j - 1), #(i - 2, j - 2), #(i - 3, j - 3)),
      #(#(i + 1, j - 1), #(i + 2, j - 2), #(i + 3, j - 3)),
      #(#(i - 1, j + 1), #(i - 2, j + 2), #(i - 3, j + 3)),
    ]

    word_positions
    |> list.fold(sum, fn(sum, positions) {
      case
        dict.get(chars, positions.0),
        dict.get(chars, positions.1),
        dict.get(chars, positions.2)
      {
        Ok("M"), Ok("A"), Ok("S") -> sum + 1
        _, _, _ -> sum
      }
    })
  })
}

pub fn part2(input: String) {
  let lines = input |> string.split("\n")
  let chars =
    lines
    |> list.index_fold(dict.new(), fn(acc, line, i) {
      string.to_graphemes(line)
      |> list.index_fold(acc, fn(acc, char, j) {
        acc |> dict.insert(#(i, j), char)
      })
    })

  let starts = chars |> dict.filter(fn(_, value) { value == "A" })

  starts
  |> dict.fold(0, fn(sum, pos, _) {
    let #(i, j) = pos

    case dict.get(chars, #(i - 1, j - 1)), dict.get(chars, #(i + 1, j + 1)) {
      Ok(x), Ok(y) if x == "M" && y == "S" || x == "S" && y == "M" -> {
        case
          dict.get(chars, #(i - 1, j + 1)),
          dict.get(chars, #(i + 1, j - 1))
        {
          Ok(x), Ok(y) if x == "M" && y == "S" || x == "S" && y == "M" ->
            sum + 1
          _, _ -> sum
        }
      }
      _, _ -> sum
    }
  })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("4")
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
