import gleam/int
import gleam/list
import gleam/string

pub type Pack =
  List(Bank)

pub type Bank =
  List(Int)

pub fn parse(input: String) -> Pack {
  use line <- list.map(string.split(input, "\n"))
  use character <- list.map(string.split(line, ""))
  let assert Ok(number) = int.parse(character)

  number
}

pub fn pt_1(input: Pack) -> Int {
  use acc, bank <- list.fold(input, 0)

  acc + find_max_joltage(bank)
}

fn find_max_joltage(input: Bank) -> Int {
  let #(first_max, rest) = find_first_largest_number(input, #(0, input))
  let assert Ok(second_max) = list.max(rest, int.compare)
  { first_max * 10 } + second_max
}

fn find_first_largest_number(
  input: List(Int),
  max: #(Int, List(Int)),
) -> #(Int, List(Int)) {
  case input {
    [first, next, ..rest] ->
      case first > max.0 {
        True -> #(first, [next, ..rest])
        False -> max
      }
      |> find_first_largest_number([next, ..rest], _)
    _ -> max
  }
}

pub fn pt_2(input: Pack) -> Int {
  todo as "part 2 not implemented"
}
