import adglent.{First, Second}
import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string

type Filesystem {
  File(size: Int, id: Int)
  Space(size: Int)
}

fn parse_input_inner(
  input: String,
  queue: Deque(Filesystem),
  index: Int,
  is_file: Bool,
) {
  case string.pop_grapheme(input) {
    Ok(#(c, rest)) -> {
      let assert Ok(n) = int.parse(c)
      parse_input_inner(
        rest,
        queue
          |> deque.push_back(case is_file {
            True -> File(size: n, id: index)
            False -> Space(size: n)
          }),
        case is_file {
          True -> index + 1
          False -> index
        },
        !is_file,
      )
    }
    _ -> queue
  }
}

fn parse_input(input: String) {
  parse_input_inner(input, deque.new(), 0, True)
}

fn interval_sum(id: Int, index: Int, n: Int) {
  id * n * { 2 * index + n - 1 } / 2
}

fn calculate_checksum_inner(queue: Deque(Filesystem), sum: Int, index: Int) {
  case deque.pop_front(queue) {
    Ok(#(File(n, id), rest)) -> {
      calculate_checksum_inner(
        rest,
        sum + interval_sum(id, index, n),
        index + n,
      )
    }
    Ok(#(Space(n), rest)) -> {
      case deque.pop_back(rest) {
        Ok(#(File(m, id), rest)) if n >= m -> {
          let rest = case deque.pop_back(rest) {
            Error(_) -> rest
            Ok(#(Space(_), rest)) -> rest
            Ok(#(file, rest)) -> rest |> deque.push_back(file)
          }
          calculate_checksum_inner(
            case n > m {
              True -> rest |> deque.push_front(Space(n - m))
              False -> rest
            },
            sum + interval_sum(id, index, m),
            index + m,
          )
        }
        Ok(#(File(m, id), rest)) if n < m -> {
          calculate_checksum_inner(
            rest |> deque.push_back(File(m - n, id)),
            sum + interval_sum(id, index, n),
            index + n,
          )
        }
        _ -> sum
      }
    }
    _ -> sum
  }
}

fn calculate_checksum(queue: Deque(Filesystem)) {
  calculate_checksum_inner(queue, 0, 0)
}

pub fn part1(input: String) {
  let queue = input |> parse_input
  queue |> calculate_checksum
}

fn queue_append(first: Deque(a), second: Deque(a)) {
  case deque.pop_front(second) {
    Ok(#(x, rest)) -> queue_append(first |> deque.push_back(x), rest)
    _ -> first
  }
}

fn queue_replace_inner(
  queue: Deque(Filesystem),
  item: Filesystem,
  with: Filesystem,
  skipped: Deque(Filesystem),
) {
  case deque.pop_back(queue) {
    Ok(#(x, rest)) if x == item ->
      queue_append(rest |> deque.push_back(with), skipped)
    Ok(#(x, rest)) ->
      queue_replace_inner(rest, item, with, skipped |> deque.push_front(x))
    _ -> skipped
  }
}

fn queue_replace(queue: Deque(Filesystem), item: Filesystem, with: Filesystem) {
  queue_replace_inner(queue, item, with, deque.new())
}

fn try_move_file_inner(
  file: Filesystem,
  queue: Deque(Filesystem),
  skipped: Deque(Filesystem),
) {
  let assert File(n, id) = file
  case deque.pop_front(queue) {
    Ok(#(File(_, other_id), _)) if other_id == id -> None
    Error(_) -> None
    Ok(#(Space(m), rest)) if m >= n -> {
      Some(
        skipped
        |> queue_append(
          rest
          |> queue_replace(file, Space(n))
          |> deque.push_front(Space(m - n))
          |> deque.push_front(File(n, id)),
        ),
      )
    }
    Ok(#(item, rest)) ->
      try_move_file_inner(file, rest, skipped |> deque.push_back(item))
  }
}

fn try_move_file(file: Filesystem, queue: Deque(Filesystem)) {
  try_move_file_inner(file, queue, deque.new())
}

fn queue_print_inner(queue: Deque(Filesystem), output: String) {
  case deque.pop_front(queue) {
    Ok(#(File(n, id), rest)) ->
      queue_print_inner(rest, output <> string.repeat(int.to_string(id), n))
    Ok(#(Space(n), rest)) ->
      queue_print_inner(rest, output <> string.repeat(".", n))
    _ -> output
  }
}

fn move_files(queue: Deque(Filesystem), compacted: Deque(Filesystem)) {
  case deque.pop_back(queue) {
    Ok(#(File(n, id), rest)) ->
      move_files(rest, case try_move_file(File(n, id), compacted) {
        Some(compacted) -> compacted
        None -> compacted
      })
    Ok(#(Space(_), rest)) -> {
      move_files(rest, compacted)
    }
    _ -> compacted
  }
}

fn calculate_checksum_without_frag(queue: Deque(Filesystem)) {
  let #(sum, _) =
    move_files(queue, queue)
    |> deque.to_list
    |> list.fold(#(0, 0), fn(acc, current) {
      let #(sum, index) = acc
      case current {
        File(n, id) -> #(sum + interval_sum(id, index, n), index + n)
        Space(n) -> #(sum, index + n)
      }
    })
  sum
}

pub fn part2(input: String) {
  let queue = input |> parse_input
  queue |> calculate_checksum_without_frag
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("9")
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
