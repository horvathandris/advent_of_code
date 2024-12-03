import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

pub type Action {
  Mul(left: Int, right: Int)
  Do
  Dont
}

pub fn parse(input: String) -> List(Action) {
  parse_loop(input, [])
}

fn parse_loop(input: String, accumulator: List(Action)) -> List(Action) {
  case input {
    "do()" <> rest -> parse_loop(rest, [Do, ..accumulator])
    "don't()" <> rest -> parse_loop(rest, [Dont, ..accumulator])
    "mul(" <> rest ->
      case parse_mul(rest) {
        Ok(#(mul, rest)) -> parse_loop(rest, [mul, ..accumulator])
        Error(rest) -> parse_loop(rest, accumulator)
      }
    _ ->
      case string.pop_grapheme(input) {
        Ok(#(_, rest)) -> parse_loop(rest, accumulator)
        _ -> accumulator
      }
  }
}

fn parse_mul(input: String) -> Result(#(Action, String), String) {
  use #(left, rest) <- result.try(parse_num(input, ","))
  use #(right, rest) <- result.try(parse_num(rest, ")"))
  Ok(#(Mul(left, right), rest))
}

fn parse_num(input: String, separator: String) -> Result(#(Int, String), String) {
  case string.split_once(input, separator) {
    Ok(#(number, rest)) ->
      int.parse(number)
      |> result.try(check_magnitude)
      |> result.map(fn(x) { #(x, rest) })
      |> result.map_error(fn(_) { input })
    _ -> Error(input)
  }
}

fn check_magnitude(number: Int) {
  case int.compare(number, 1000) {
    order.Lt -> Ok(number)
    _ -> Error(Nil)
  }
}

pub fn pt_1(input: List(Action)) -> Int {
  use acc, action <- list.fold(input, 0)
  case action {
    Mul(left, right) -> left * right + acc
    _ -> acc
  }
}

pub fn pt_2(input: List(Action)) -> Int {
  list.reverse(input)
  |> list.fold(#(0, True), fn(acc, action) {
    case action, acc {
      Do, #(sum, _) -> #(sum, True)
      Dont, #(sum, _) -> #(sum, False)
      Mul(left, right), #(sum, True) -> #(sum + left * right, True)
      _, _ -> acc
    }
  })
  |> fn(acc) { acc.0 }
}
