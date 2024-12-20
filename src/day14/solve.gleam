import adglent.{First, Second}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp.{Match}
import gleam/result
import gleam/set
import gleam/string
import gleam/yielder
import gleam_community/maths/arithmetics.{int_euclidean_modulo}
import tote/bag

type Robot {
  Robot(pos: #(Int, Int), vel: #(Int, Int))
}

fn parse_input(input: String) {
  let assert Ok(re) = regexp.from_string("p=(.+),(.+) v=(.+),(.+)")
  use line <- list.map(input |> string.split("\n"))
  let assert [Match(_, params)] = re |> regexp.scan(line)
  let assert [x, y, vx, vy] =
    params
    |> list.map(option.unwrap(_, "0"))
    |> list.map(int.parse)
    |> result.values

  Robot(pos: #(x, y), vel: #(vx, vy))
}

pub fn part1(input: String, width: Int, height: Int) {
  input
  |> parse_input
  |> list.fold(bag.new(), fn(acc, robot) {
    let Robot(pos: #(x, y), vel: #(vx, vy)) = robot
    let new_pos = #(
      int_euclidean_modulo(x + 100 * vx, width),
      int_euclidean_modulo(y + 100 * vy, height),
    )
    case new_pos {
      #(x, y) if x < width / 2 && y < height / 2 -> acc |> bag.insert(1, "tl")
      #(x, y) if x > width / 2 && y < height / 2 -> acc |> bag.insert(1, "tr")
      #(x, y) if x < width / 2 && y > height / 2 -> acc |> bag.insert(1, "bl")
      #(x, y) if x > width / 2 && y > height / 2 -> acc |> bag.insert(1, "br")
      _ -> acc
    }
  })
  |> bag.fold(1, fn(acc, _, count) { acc * count })
}

pub fn part2(input: String, width: Int, height: Int) {
  let robots = input |> parse_input
  let num_robots = robots |> list.length |> int.to_float

  // The positions will repeat after a certain number of steps
  // so we can calculate all unique positions
  let robot_positions =
    yielder.unfold(#(robots, set.new()), fn(acc) {
      let #(robots, seen) = acc
      case seen |> set.contains(robots) {
        True -> yielder.Done
        _ -> {
          let seen = seen |> set.insert(robots)
          let robots =
            robots
            |> list.map(fn(robot) {
              let Robot(pos: #(x, y), vel: #(vx, vy)) = robot
              Robot(
                pos: #(
                  int_euclidean_modulo(x + vx, width),
                  int_euclidean_modulo(y + vy, height),
                ),
                vel: #(vx, vy),
              )
            })
          yielder.Next(element: robots, accumulator: #(robots, seen))
        }
      }
    })

  // The positions are usually random but we assume that in order to form a
  // christmas tree, most of the robots will be closely packed together
  // so we find the one with the smallest variance
  let #(_, index) =
    robot_positions
    |> yielder.map(fn(robots) {
      let mean = {
        let #(x, y) =
          robots
          |> list.fold(#(0.0, 0.0), fn(acc, robot) {
            #(
              acc.0 +. int.to_float(robot.pos.0),
              acc.1 +. int.to_float(robot.pos.1),
            )
          })
        #(x /. num_robots, y /. num_robots)
      }

      let sum =
        robots
        |> list.fold(0.0, fn(acc, robot) {
          acc
          +. float.absolute_value(int.to_float(robot.pos.0) -. mean.0)
          +. float.absolute_value(int.to_float(robot.pos.1) -. mean.1)
        })

      sum /. num_robots
    })
    |> yielder.index
    |> yielder.fold(#(999_999.0, 0), fn(acc, e) {
      let #(min_var, _) = acc
      case e.0 <. min_var {
        True -> #(e.0, e.1)
        _ -> acc
      }
    })

  // Draw the christmas tree
  let assert Ok(christmas_tree_robots) = robot_positions |> yielder.at(index)

  let christmas_tree_positions =
    christmas_tree_robots
    |> list.fold(set.new(), fn(acc, robot) { acc |> set.insert(robot.pos) })

  list.range(0, height - 1)
  |> list.each(fn(y) {
    list.range(0, width - 1)
    |> list.each(fn(x) {
      case christmas_tree_positions |> set.contains(#(x, y)) {
        True -> io.print("#")
        _ -> io.print(" ")
      }
    })
    io.println("")
  })

  index + 1
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("14")
  case part {
    First ->
      part1(input, 101, 103)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input, 101, 103)
      |> adglent.inspect
      |> io.println
  }
}
