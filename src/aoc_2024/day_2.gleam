import gleam/bool.{and, or}
import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub type ParsedInput =
  List(List(Int))

pub fn parse(input: String) -> ParsedInput {
  string.split(input, " ")
  |> list.fold([[]], fn(acc, number) {
    case string.split_once(number, "\n") {
      Ok(#(number1, number2)) -> {
        let assert [current_row, ..rest] = acc
        [[parse_int(number2)], [parse_int(number1), ..current_row], ..rest]
      }
      _ -> {
        let assert [current_row, ..rest] = acc
        [[parse_int(number), ..current_row], ..rest]
      }
    }
  })
}

fn parse_int(input: String) -> Int {
  let assert Ok(int) = int.parse(input)
  int
}

pub fn pt_1(input: ParsedInput) -> Int {
  list.map(input, fn(row) {
    let assert [current, ..rest] = row
    fold_row_loop(current, rest, order.Eq)
  })
  |> list.count(fn(safe) { safe })
}

fn fold_row_loop(current: Int, rest: List(Int), ord: order.Order) -> Bool {
  case rest {
    [] -> True
    [next, ..rest] -> {
      let diff = int.subtract(current, next)
      case or(and(diff < 4, diff > 0), and(diff > -4, diff < 0)) {
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

pub fn pt_2(input: ParsedInput) -> Int {
  list.map(input, fn(row) {
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
  |> list.count(fn(safe) { safe })
}

fn create_permutations(original: List(Int)) -> List(List(Int)) {
  let keyed_original = list.index_map(original, fn(item, i) { #(i, item) })

  list.index_map(original, fn(_, i) {
    let assert Ok(#(_, new_row)) = list.key_pop(keyed_original, i)
    list.map(new_row, fn(level) { level.1 })
  })
}
