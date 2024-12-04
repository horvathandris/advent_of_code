import gleam/bool
import gleam/dict.{type Dict}
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
  search_for_x(input, #(0, 0), 0)
}

fn search_for_x(input: Matrix, location: Location, accumulator: Int) -> Int {
  let assert Ok(char) = dict.get(input.matrix, location)
  let new_accumulator = case char {
    "X" -> accumulator + check_xmas(input, location)
    _ -> accumulator
  }
  next_location(location, input.size)
  |> result.map(search_for_x(input, _, new_accumulator))
  |> result.unwrap(new_accumulator)
}

fn check_xmas(input: Matrix, location: Location) -> Int {
  generate_sequences(location, input.size)
  |> list.map(fn(sequence) {
    list.map(sequence, dict.get(input.matrix, _))
    |> result.all
    |> result.map(string.join(_, ""))
    |> result.try(verify_sequence(_))
  })
  |> list.count(result.is_ok)
}

fn verify_sequence(sequence: String) -> Result(Nil, Nil) {
  case sequence {
    "MAS" -> Ok(Nil)
    _ -> Error(Nil)
  }
}

fn generate_sequences(location: Location, size: Int) -> List(List(Location)) {
  use sequence <- list.filter(direction_sequences(location))
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
  todo as "part 2 not implemented"
}
