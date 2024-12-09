import gleam/bool.{and}
import gleam/int
import gleam/list
import gleam/order
import gleam/string
import util

pub type ParsedInput =
  List(List(Int))

pub fn parse(input: String) -> ParsedInput {
  use line <- list.map(string.split(input, "\n"))
  string.split(line, " ")
  |> list.map(util.parse_int)
}

pub fn pt_1(input: ParsedInput) -> Int {
  list.filter(input, fn(row) {
    let assert [current, ..rest] = row
    fold_row_loop(current, rest, order.Eq)
  })
  |> list.length
}

fn fold_row_loop(current: Int, rest: List(Int), ord: order.Order) -> Bool {
  case rest {
    [] -> True
    [next, ..rest] -> {
      let diff = int.subtract(current, next)
      case in_range(diff, -3, -1) || in_range(diff, 1, 3) {
        True ->
          case ord {
            order.Eq -> fold_row_loop(next, rest, int.compare(current, next))
            _ ->
              case int.compare(current, next) |> order.compare(ord) {
                order.Eq -> fold_row_loop(next, rest, ord)
                _ -> False
              }
          }
        False -> False
      }
    }
  }
}

fn in_range(number: Int, min: Int, max: Int) -> Bool {
  and(number >= min, number <= max)
}

pub fn pt_2(input: ParsedInput) -> Int {
  list.filter(input, fn(row) {
    let assert [current, ..rest] = row
    case fold_row_loop(current, rest, order.Eq) {
      True -> True
      False -> {
        create_permutations(row)
        |> list.any(fn(new_row) {
          let assert [current, ..rest] = new_row
          fold_row_loop(current, rest, order.Eq)
        })
      }
    }
  })
  |> list.length
}

fn create_permutations(original: List(Int)) -> List(List(Int)) {
  let keyed_original = list.index_map(original, fn(item, i) { #(i, item) })

  use _, i <- list.index_map(original)
  let assert Ok(#(_, new_row)) = list.key_pop(keyed_original, i)
  list.map(new_row, fn(level) { level.1 })
}
