import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import tote/bag

fn count_stones(input: String, steps: Int) {
  let assert Ok(stones) =
    input
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.values
    |> bag.from_list
    |> yielder.iterate(fn(stones) {
      stones
      |> bag.fold(bag.new(), fn(acc, stone, count) {
        case stone {
          0 -> acc |> bag.insert(count, 1)
          _ -> {
            let assert Ok(digits) = stone |> int.digits(10)
            case digits |> list.length {
              n if n % 2 == 0 -> {
                let #(a, b) = digits |> list.split(n / 2)
                let assert [a, b] =
                  [a, b] |> list.map(int.undigits(_, 10)) |> result.values
                acc |> bag.insert(count, a) |> bag.insert(count, b)
              }
              _ -> acc |> bag.insert(count, stone * 2024)
            }
          }
        }
      })
    })
    |> yielder.at(steps)

  stones |> bag.size
}

pub fn part1(input: String) {
  input |> count_stones(25)
}

pub fn part2(input: String) {
  input |> count_stones(75)
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("11")
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
