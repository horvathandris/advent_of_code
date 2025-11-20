import common.{type Direction, type Location}
import gleam/io
import gleam/list
import gleam/option
import gleam/set.{type Set}
import gleam/string

pub type Maze {
  Maze(walls: Set(Location), current: Location, end: Location)
}

pub fn parse(input: String) -> Maze {
  string.split(input, "\n")
  |> list.index_fold(
    Maze(set.new(), current: #(0, 0), end: #(0, 0)),
    fn(maze, line, i) {
      string.split(line, "")
      |> list.index_fold(maze, fn(inner, char, j) {
        case char {
          "#" -> Maze(..inner, walls: set.insert(inner.walls, #(i, j)))
          "S" -> Maze(..inner, current: #(i, j))
          "E" -> Maze(..inner, end: #(i, j))
          _ -> inner
        }
      })
    },
  )
}

fn a_star(
  maze: Maze,
  last: option.Option(#(Direction, Location)),
  _seen: set.Set(Location),
  _cost: Int,
) -> Result(Int, Nil) {
  case last {
    option.None -> todo
    option.Some(#(_direction, last_node)) ->
      case last_node == maze.end {
        False -> todo
        True -> todo
      }
  }
}

pub fn pt_1(input: Maze) -> Int {
  io.debug(input)
  let _ = a_star(input, option.None, set.new(), 0)
  todo as "part 1 not implemented"
}

pub fn pt_2(_input: Maze) {
  todo as "part 2 not implemented"
}
