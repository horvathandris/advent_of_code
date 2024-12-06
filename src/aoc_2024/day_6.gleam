import gleam/dict
import gleam/io
import gleam/list
import gleam/string

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
  io.debug(input)
  todo as "part 1 not implemented"
}

pub fn pt_2(input: Matrix) -> Int {
  todo as "part 2 not implemented"
}
