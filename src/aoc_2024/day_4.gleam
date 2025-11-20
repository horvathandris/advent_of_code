import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Matrix {
  Matrix(matrix: Dict(Location, String), size: Int)
}

type Location =
  #(Int, Int)

pub fn parse(input: String) -> Matrix {
  let lines = string.split(input, "\n")
  let size = list.length(lines)

  lines
  |> list.index_map(fn(line, i) {
    string.to_graphemes(line)
    |> list.index_map(fn(char, j) { #(#(i, j), char) })
  })
  |> list.flatten
  |> dict.from_list
  |> Matrix(size:)
}

pub fn pt_1(input: Matrix) -> Int {
  use input, location <- search_for_char(input, #(0, 0), 0, "X")
  check_xmas(input, location, direction_sequences)
}

fn search_for_char(
  input: Matrix,
  location: Location,
  accumulator: Int,
  character: String,
  checker: fn(Matrix, Location) -> Int,
) -> Int {
  let new_accumulator = case dict.get(input.matrix, location) {
    Ok(char) if char == character -> accumulator + checker(input, location)
    _ -> accumulator
  }
  next_location(location, input.size)
  |> result.map(search_for_char(input, _, new_accumulator, character, checker))
  |> result.unwrap(new_accumulator)
}

fn check_xmas(
  input: Matrix,
  location: Location,
  sequence_generator: fn(Location) -> List(List(Location)),
) -> Int {
  generate_sequences(location, input.size, sequence_generator)
  |> list.map(fn(sequence) {
    list.map(sequence, dict.get(input.matrix, _))
    |> result.all
    |> result.map(string.join(_, ""))
    |> result.try(verify_sequence)
  })
  |> list.count(result.is_ok)
}

fn verify_sequence(sequence: String) -> Result(Nil, Nil) {
  case sequence {
    "MAS" -> Ok(Nil)
    _ -> Error(Nil)
  }
}

fn generate_sequences(
  location: Location,
  size: Int,
  generator: fn(Location) -> List(List(Location)),
) -> List(List(Location)) {
  use sequence <- list.filter(generator(location))
  list.all(sequence, check_out_of_bounds(_, size))
}

fn direction_sequences(location: Location) -> List(List(Location)) {
  [
    // east
    [
      #(location.0, location.1 + 1),
      #(location.0, location.1 + 2),
      #(location.0, location.1 + 3),
    ],
    // southeast
    [
      #(location.0 + 1, location.1 + 1),
      #(location.0 + 2, location.1 + 2),
      #(location.0 + 3, location.1 + 3),
    ],
    // south
    [
      #(location.0 + 1, location.1),
      #(location.0 + 2, location.1),
      #(location.0 + 3, location.1),
    ],
    // southwest
    [
      #(location.0 + 1, location.1 - 1),
      #(location.0 + 2, location.1 - 2),
      #(location.0 + 3, location.1 - 3),
    ],
    // west
    [
      #(location.0, location.1 - 1),
      #(location.0, location.1 - 2),
      #(location.0, location.1 - 3),
    ],
    // northwest
    [
      #(location.0 - 1, location.1 - 1),
      #(location.0 - 2, location.1 - 2),
      #(location.0 - 3, location.1 - 3),
    ],
    // north
    [
      #(location.0 - 1, location.1),
      #(location.0 - 2, location.1),
      #(location.0 - 3, location.1),
    ],
    // northeast
    [
      #(location.0 - 1, location.1 + 1),
      #(location.0 - 2, location.1 + 2),
      #(location.0 - 3, location.1 + 3),
    ],
  ]
}

fn next_location(location: Location, size: Int) -> Result(Location, Nil) {
  case location.1 + 1 < size, location.0 + 1 < size {
    True, _ -> Ok(#(location.0, location.1 + 1))
    False, True -> Ok(#(location.0 + 1, 0))
    _, _ -> Error(Nil)
  }
}

fn check_out_of_bounds(location: Location, size: Int) -> Bool {
  bool.and(location.0 < size, location.1 < size)
}

pub fn pt_2(input: Matrix) -> Int {
  use input, location <- search_for_char(input, #(0, 0), 0, "A")
  check_xmas(input, location, cross_sequences)
  |> int.floor_divide(2)
  |> result.unwrap(0)
}

fn cross_sequences(location: Location) {
  [
    [
      #(location.0 - 1, location.1 - 1),
      #(location.0, location.1),
      #(location.0 + 1, location.1 + 1),
    ],
    [
      #(location.0 - 1, location.1 + 1),
      #(location.0, location.1),
      #(location.0 + 1, location.1 - 1),
    ],
    [
      #(location.0 + 1, location.1 + 1),
      #(location.0, location.1),
      #(location.0 - 1, location.1 - 1),
    ],
    [
      #(location.0 + 1, location.1 - 1),
      #(location.0, location.1),
      #(location.0 - 1, location.1 + 1),
    ],
  ]
}
