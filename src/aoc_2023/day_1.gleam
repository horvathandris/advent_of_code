import gleam/list
import gleam/result
import gleam/string

pub type ParsedInput {
  ParsedInput(lines: List(String))
}

pub fn parse(input: String) -> ParsedInput {
  string.split(input, "\n")
  |> ParsedInput
}

pub fn pt_1(input: ParsedInput) -> Int {
  use sum, line <- list.fold(input.lines, 0)

  let digits =
    string.split(line, "")
    |> list.filter_map(to_digit)

  let first =
    list.first(digits)
    |> result.unwrap(0)

  let last =
    list.last(digits)
    |> result.unwrap(0)

  sum + { 10 * first } + last
}

pub fn pt_2(input: ParsedInput) -> Int {
  use sum, line <- list.fold(input.lines, 0)
  let digits = try_parse_digits(line, [])

  // `digits` is in reverse order
  let first =
    list.last(digits)
    |> result.unwrap(0)

  let last =
    list.first(digits)
    |> result.unwrap(0)

  sum + { 10 * first } + last
}

fn try_parse_digits(word: String, accumulator: List(Int)) -> List(Int) {
  string.pop_grapheme(word)
  |> result.map(fn(first_and_rest) {
    let tail = first_and_rest.1
    case word {
      "one" <> _ | "1" <> _ -> [1, ..accumulator]
      "two" <> _ | "2" <> _ -> [2, ..accumulator]
      "three" <> _ | "3" <> _ -> [3, ..accumulator]
      "four" <> _ | "4" <> _ -> [4, ..accumulator]
      "five" <> _ | "5" <> _ -> [5, ..accumulator]
      "six" <> _ | "6" <> _ -> [6, ..accumulator]
      "seven" <> _ | "7" <> _ -> [7, ..accumulator]
      "eight" <> _ | "8" <> _ -> [8, ..accumulator]
      "nine" <> _ | "9" <> _ -> [9, ..accumulator]
      _ -> accumulator
    }
    |> try_parse_digits(tail, _)
  })
  |> result.unwrap(accumulator)
}

fn to_digit(char: String) -> Result(Int, Nil) {
  case char {
    "1" -> Ok(1)
    "2" -> Ok(2)
    "3" -> Ok(3)
    "4" -> Ok(4)
    "5" -> Ok(5)
    "6" -> Ok(6)
    "7" -> Ok(7)
    "8" -> Ok(8)
    "9" -> Ok(9)
    _ -> Error(Nil)
  }
}
