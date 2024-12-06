import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import parallel_map

pub type Location =
  #(Int, Int)

pub type Direction {
  North
  East
  South
  West
}

pub type Guard {
  Guard(location: Location, direction: Direction)
}

pub type Matrix {
  Matrix(matrix: dict.Dict(Location, Bool), size: Int, guard: Guard)
}

pub fn parse(input: String) -> Matrix {
  let lines = string.split(input, "\n")
  let size = list.length(lines)
  let #(matrix, guard) =
    {
      use line, i <- list.index_map(lines)
      use char, j <- list.index_map(string.to_graphemes(line))
      #(#(i, j), char)
    }
    |> list.flatten
    |> list.fold(#(dict.new(), Guard(#(0, 0), North)), fn(acc, cell) {
      case cell.1 {
        "." -> #(dict.insert(acc.0, cell.0, False), acc.1)
        "#" -> #(dict.insert(acc.0, cell.0, True), acc.1)
        _ -> #(dict.insert(acc.0, cell.0, False), Guard(cell.0, North))
      }
    })

  Matrix(matrix, size, guard)
}

pub fn pt_1(input: Matrix) -> Int {
  patrol_loop(input, set.new())
  |> set.size
}

fn patrol_loop(input: Matrix, seen: Set(Location)) -> Set(Location) {
  case next_location(input.size, input.guard) {
    None -> set.insert(seen, input.guard.location)
    Some(location) ->
      case dict.get(input.matrix, location) {
        Ok(False) ->
          patrol_loop(
            Matrix(
              input.matrix,
              input.size,
              Guard(location, input.guard.direction),
            ),
            set.insert(seen, input.guard.location),
          )
        _ ->
          patrol_loop(
            Matrix(input.matrix, input.size, turn_guard(input.guard)),
            set.insert(seen, input.guard.location),
          )
      }
  }
}

fn next_location(size: Int, guard: Guard) -> Option(Location) {
  case guard.direction {
    North -> #(guard.location.0 - 1, guard.location.1)
    East -> #(guard.location.0, guard.location.1 + 1)
    South -> #(guard.location.0 + 1, guard.location.1)
    West -> #(guard.location.0, guard.location.1 - 1)
  }
  |> validate_location(size)
}

fn validate_location(location: Location, size: Int) -> Option(Location) {
  case between(location.0, 0, size - 1) && between(location.1, 0, size - 1) {
    True -> Some(location)
    _ -> None
  }
}

fn between(num: Int, min: Int, max: Int) -> Bool {
  num >= min && num <= max
}

fn turn_guard(guard: Guard) -> Guard {
  case guard.direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }
  |> Guard(guard.location, _)
}

pub fn pt_2(input: Matrix) -> Int {
  let fun = fn(location) {
    patrol_loop_mod(
      Matrix(dict.insert(input.matrix, location, True), input.size, input.guard),
      set.new(),
    )
  }

  patrol_loop(input, set.new())
  |> set.to_list
  |> parallel_map.list_pmap(fun, parallel_map.MatchSchedulersOnline, 1000)
  |> list.count(result.unwrap(_, False))
}

fn patrol_loop_mod(input: Matrix, seen: Set(Guard)) -> Bool {
  case next_location(input.size, input.guard) {
    None -> False
    Some(location) ->
      case set.contains(seen, Guard(location, input.guard.direction)) {
        True -> True
        False ->
          case dict.get(input.matrix, location) {
            Ok(False) ->
              patrol_loop_mod(
                Matrix(
                  input.matrix,
                  input.size,
                  Guard(location, input.guard.direction),
                ),
                set.insert(seen, input.guard),
              )
            _ ->
              patrol_loop_mod(
                Matrix(input.matrix, input.size, turn_guard(input.guard)),
                set.insert(seen, input.guard),
              )
          }
      }
  }
}
