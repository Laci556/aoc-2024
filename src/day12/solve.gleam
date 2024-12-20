import adglent.{First, Second}
import gleam/bool
import gleam/deque
import gleam/dict
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import gleam/yielder.{Done, Next}

fn parse_input(input: String) {
  use acc, line, row <- list.index_fold(input |> string.split("\n"), dict.new())
  use acc, char, col <- list.index_fold(line |> string.to_graphemes, acc)
  acc |> dict.insert(#(row, col), char)
}

const offsets = [#(-1, 0), #(0, 1), #(0, -1), #(1, 0)]

fn get_plots(input: String) {
  let input = input |> parse_input
  let unvisited = input |> dict.keys |> set.from_list

  unvisited
  |> yielder.unfold(fn(unvisited) {
    use <- bool.guard(unvisited |> set.is_empty, Done)

    let assert [start_pos, ..] = unvisited |> set.to_list
    let assert Ok(start_letter) = input |> dict.get(start_pos)

    let plot =
      #(unvisited |> set.delete(start_pos), deque.from_list([start_pos]))
      |> yielder.unfold(fn(acc) {
        let #(unvisited, to_visit) = acc
        use <- bool.guard(to_visit |> deque.is_empty, Done)

        let assert Ok(#(pos, to_visit)) = to_visit |> deque.pop_front()

        let #(unvisited, to_visit) =
          offsets
          |> list.fold(#(unvisited, to_visit), fn(acc, offset) {
            let #(unvisited, to_visit) = acc
            let next_pos = #(pos.0 + offset.0, pos.1 + offset.1)
            use <- bool.guard(!{ unvisited |> set.contains(next_pos) }, #(
              unvisited,
              to_visit,
            ))

            case input |> dict.get(next_pos) {
              Ok(letter) if letter == start_letter -> #(
                unvisited |> set.delete(next_pos),
                to_visit |> deque.push_back(next_pos),
              )
              _ -> #(unvisited, to_visit)
            }
          })

        Next(element: pos, accumulator: #(unvisited, to_visit))
      })
      |> yielder.fold(set.new(), fn(plot, pos) { plot |> set.insert(pos) })

    Next(element: plot, accumulator: unvisited |> set.difference(plot))
  })
}

pub fn part1(input: String) {
  get_plots(input)
  |> yielder.fold(0, fn(acc, plot) {
    let area = plot |> set.size
    let perimeter =
      plot
      |> set.fold(0, fn(perimeter, pos) {
        perimeter
        + list.fold(offsets, 4, fn(perimeter, offset) {
          let next_pos = #(pos.0 + offset.0, pos.1 + offset.1)
          case plot |> set.contains(next_pos) {
            True -> perimeter - 1
            _ -> perimeter
          }
        })
      })
    acc + area * perimeter
  })
}

pub fn part2(input: String) {
  get_plots(input)
  |> yielder.fold(0, fn(acc, plot) {
    let area = plot |> set.size
    let sides =
      plot
      |> set.fold(0, fn(acc, pos) {
        let sides =
          [
            #(#(-1, 0), #(0, 1)),
            #(#(0, 1), #(1, 0)),
            #(#(1, 0), #(0, -1)),
            #(#(0, -1), #(-1, 0)),
          ]
          |> list.fold(0, fn(acc, offsets) {
            let #(offset1, offset2) = offsets
            let neighbor1 = #(pos.0 + offset1.0, pos.1 + offset1.1)
            let neighbor2 = #(pos.0 + offset2.0, pos.1 + offset2.1)

            case
              plot |> set.contains(neighbor1),
              plot |> set.contains(neighbor2)
            {
              False, False -> acc + 1
              True, True -> {
                use <- bool.guard(
                  plot
                    |> set.contains(#(
                      pos.0 + offset1.0 + offset2.0,
                      pos.1 + offset1.1 + offset2.1,
                    )),
                  acc,
                )
                acc + 1
              }
              _, _ -> acc
            }
          })
        acc + sides
      })
    acc + area * sides
  })
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("12")
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
