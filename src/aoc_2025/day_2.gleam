import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam_community/maths

pub type Range =
  #(Int, Int)

pub fn parse(input: String) -> List(Range) {
  use range <- list.map(string.split(input, ","))

  let assert Ok(#(start, end)) = string.split_once(range, "-")
  let assert Ok(start) = int.parse(start)
  let assert Ok(end) = int.parse(end)

  #(start, end)
}

pub fn pt_1(input: List(Range)) -> Int {
  use acc, #(start, end) <- list.fold(input, 0)
  use inner_acc, number <- list.fold(list.range(start, end), acc)

  let magnitude = get_magnitude(number) + 1

  case int.modulo(magnitude, 2) {
    Ok(0) -> check(number, magnitude) + inner_acc
    _ -> inner_acc
  }
}

fn get_magnitude(number: Int) -> Int {
  int.to_float(number)
  |> maths.logarithm_10
  |> result.map(float.truncate)
  |> result.unwrap(0)
}

fn check(number: Int, magnitude: Int) -> Int {
  let str_number = int.to_string(number)

  let to_check =
    str_number
    |> string.slice(at_index: 0, length: magnitude / 2)

  case string.ends_with(str_number, to_check) {
    True -> number
    False -> 0
  }
}

pub fn pt_2(input: List(Range)) {
  use acc, #(start, end) <- list.fold(input, 0)
  use inner_acc, number <- list.fold(list.range(start, end), acc)

  inner_acc + check_2(number)
}

fn check_2(number: Int) {
  let is_invalid = case number {
    number if 10 < number && number <= 99 -> int.modulo(number, 11) == Ok(0)
    number if 100 < number && number <= 999 -> int.modulo(number, 111) == Ok(0)
    number if 1000 < number && number <= 9999 ->
      int.modulo(number, 101) == Ok(0) || int.modulo(number, 1111) == Ok(0)
    number if 10_000 < number && number <= 99_999 ->
      int.modulo(number, 11_111) == Ok(0)
    number if 100_000 < number && number <= 999_999 ->
      int.modulo(number, 1001) == Ok(0)
      || int.modulo(number, 10_101) == Ok(0)
      || int.modulo(number, 111_111) == Ok(0)
    number if 1_000_000 < number && number <= 9_999_999 ->
      int.modulo(number, 1_111_111) == Ok(0)
    number if 10_000_000 < number && number <= 99_999_999 ->
      int.modulo(number, 10_001) == Ok(0)
      || int.modulo(number, 1_010_101) == Ok(0)
      || int.modulo(number, 11_111_111) == Ok(0)
    number if 100_000_000 < number && number <= 999_999_999 ->
      int.modulo(number, 1_001_001) == Ok(0)
      || int.modulo(number, 111_111_111) == Ok(0)
    number if 1_000_000_000 < number && number <= 9_999_999_999 ->
      int.modulo(number, 100_001) == Ok(0)
      || int.modulo(number, 101_010_101) == Ok(0)
      || int.modulo(number, 1_111_111_111) == Ok(0)
    _ -> False
  }

  case is_invalid {
    True -> number
    False -> 0
  }
}
