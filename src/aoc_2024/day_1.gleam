import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type ParsedInput =
  #(List(Int), List(Int))

pub fn parse(input: String) -> ParsedInput {
  parse_loop(input, #([], []), True)
}

fn parse_loop(
  input: String,
  accumulator: ParsedInput,
  left_col: Bool,
) -> ParsedInput {
  case left_col {
    True -> {
      let assert Ok(#(number, rest)) = string.split_once(input, "   ")
      parse_loop(rest, new_accumulator(number, accumulator, False), False)
    }
    False -> {
      case string.split_once(input, "\n") {
        Ok(#(number, rest)) ->
          parse_loop(rest, new_accumulator(number, accumulator, True), True)
        _ -> new_accumulator(input, accumulator, True)
      }
    }
  }
}

fn parse_int(input: String) -> Int {
  let assert Ok(int) = int.parse(input)
  int
}

fn new_accumulator(input: String, acc: ParsedInput, left: Bool) -> ParsedInput {
  case left {
    True -> #([parse_int(input), ..acc.0], acc.1)
    False -> #(acc.0, [parse_int(input), ..acc.1])
  }
}

pub fn pt_1(input: ParsedInput) -> Int {
  list.map2(
    list.sort(input.0, int.compare),
    list.sort(input.1, int.compare),
    fn(left, right) { int.absolute_value(left - right) },
  )
  |> list.reduce(int.add)
  |> result.lazy_unwrap(fn() { 0 })
}

pub fn pt_2(input: ParsedInput) -> Int {
  list.map(input.0, fn(left) {
    list.filter(input.1, fn(right) { left == right })
    |> list.length
    |> int.multiply(left)
  })
  |> list.reduce(int.add)
  |> result.lazy_unwrap(fn() { 0 })
}
