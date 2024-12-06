import adglent.{First, Second}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/set.{type Set}
import gleam/string

/// Parses the input into a tuple of rules and updates.
fn parse_input(input: String) {
  let assert [rules, updates] =
    input
    |> string.split("\n\n")
    |> list.map(fn(x) { string.split(x, "\n") })

  // the rules are a map from numbers to sets of numbers that must come before them
  let rules =
    rules
    |> list.fold(dict.new(), fn(acc, x) {
      let assert [a, b] =
        x
        |> string.split("|")
        |> list.map(int.parse)
        |> result.values
      dict.upsert(acc, b, fn(entry) {
        case entry {
          Some(v) -> set.insert(v, a)
          None -> set.from_list([a])
        }
      })
    })

  let updates =
    updates
    |> list.map(fn(x) {
      x |> string.split(",") |> list.map(int.parse) |> result.values
    })

  #(rules, updates)
}

/// Checks if an update is valid given a set of rules.
fn is_update_valid(update: List(Int), rules: Dict(Int, Set(Int))) {
  list.fold_until(update, #(True, set.new()), fn(acc, x) {
    use <- bool.guard(set.contains(acc.1, x), Stop(#(False, acc.1)))

    case dict.get(rules, x) {
      Ok(disallowed) -> Continue(#(True, set.union(acc.1, disallowed)))
      _ -> Continue(acc)
    }
  }).0
}

/// Sums the middle elements of all valid updates.
fn sum_middles(updates: List(List(Int))) {
  updates
  |> list.fold(0, fn(acc, valid) {
    let len = list.length(valid)
    let assert [middle, ..] = valid |> list.drop(len / 2)
    acc + middle
  })
}

pub fn part1(input: String) {
  let #(rules, updates) = input |> parse_input

  updates
  |> list.filter(fn(update) { update |> is_update_valid(rules) })
  |> sum_middles
}

pub fn part2(input: String) {
  let #(rules, updates) = input |> parse_input

  updates
  |> list.filter(fn(update) { !{ update |> is_update_valid(rules) } })
  |> list.map(fn(update) {
    // short the updates by the rules
    list.sort(update, fn(a, b) {
      case dict.get(rules, a), dict.get(rules, b) {
        Ok(before_a), Ok(before_b) -> {
          // b has to come before a -> a > b
          use <- bool.guard(set.contains(before_a, b), Gt)
          // a has to come before b -> a < b
          use <- bool.guard(set.contains(before_b, a), Lt)
          // otherwise don't change the order
          Eq
        }
        Ok(before_a), _ -> {
          use <- bool.guard(set.contains(before_a, b), Gt)
          Eq
        }
        _, Ok(before_b) -> {
          use <- bool.guard(set.contains(before_b, a), Lt)
          Eq
        }
        _, _ -> Eq
      }
    })
  })
  |> sum_middles
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("5")
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
