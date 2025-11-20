import common.{type Direction, type Location, East, North, South, West}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import util

pub type Block {
  Wall
  Box
}

pub type Map {
  Map(blocks: Dict(Location, Block), size: #(Int, Int), robot: Location)
}

pub fn parse(input: String) -> #(Map, List(Direction)) {
  let #(map, moves) = util.split_once(input, "\n\n")
  #(parse_map(map), parse_moves(moves))
}

fn parse_map(input: String) -> Map {
  use acc, line, i <- list.index_fold(
    string.split(input, "\n"),
    Map(dict.new(), #(0, 0), #(0, 0)),
  )
  use inner_acc, char, j <- list.index_fold(string.split(line, ""), acc)
  case char {
    "#" ->
      Map(
        ..inner_acc,
        blocks: dict.insert(inner_acc.blocks, #(i, j), Wall),
        size: #(i, j),
      )
    "O" -> Map(..inner_acc, blocks: dict.insert(inner_acc.blocks, #(i, j), Box))
    "@" -> Map(..inner_acc, robot: #(i, j))
    _ -> inner_acc
  }
}

fn parse_moves(input: String) -> List(Direction) {
  use char <- list.filter_map(string.split(input, ""))
  case char {
    ">" -> Ok(East)
    "v" -> Ok(South)
    "<" -> Ok(West)
    "^" -> Ok(North)
    _ -> Error(Nil)
  }
}

pub fn pt_1(input: #(Map, List(Direction))) -> Int {
  let #(map, directions) = input
  list.fold(directions, map, move_robot).blocks
  |> dict.filter(fn(_, block) {
    case block {
      Wall -> False
      Box -> True
    }
  })
  |> dict.keys
  |> list.map(calculate_gps)
  |> list.fold(0, int.add)
}

fn move_robot(map: Map, direction: Direction) -> Map {
  let next_robot_location = next_location(map.robot, direction)
  case dict.get(map.blocks, next_robot_location) {
    Error(_) -> Map(..map, robot: next_robot_location)
    Ok(Wall) -> map
    Ok(Box) -> {
      let #(new_map, success) = move_box(map, next_robot_location, direction)
      case success {
        False -> map
        True -> Map(..new_map, robot: next_robot_location)
      }
    }
  }
}

fn move_box(
  map: Map,
  box_location: Location,
  direction: Direction,
) -> #(Map, Bool) {
  let next_box_location = next_location(box_location, direction)
  case dict.get(map.blocks, next_box_location) {
    Error(_) -> #(
      Map(
        ..map,
        blocks: map.blocks
          |> dict.delete(box_location)
          |> dict.insert(next_box_location, Box),
      ),
      True,
    )
    Ok(Wall) -> #(map, False)
    Ok(Box) -> {
      let #(new_map, success) = move_box(map, next_box_location, direction)
      case success {
        False -> #(map, False)
        True -> #(
          Map(
            ..new_map,
            blocks: new_map.blocks
              |> dict.delete(box_location)
              |> dict.insert(next_box_location, Box),
          ),
          True,
        )
      }
    }
  }
}

fn next_location(location: Location, direction: Direction) -> Location {
  case direction {
    East -> #(location.0, location.1 + 1)
    South -> #(location.0 + 1, location.1)
    West -> #(location.0, location.1 - 1)
    North -> #(location.0 - 1, location.1)
  }
}

fn calculate_gps(location: Location) -> Int {
  { 100 * location.0 } + location.1
}

pub fn pt_2(_input: #(Map, List(Direction))) -> Int {
  todo as "part 2 not implemented"
}

fn print_map(map: Map) -> String {
  list.range(0, map.size.0)
  |> list.map(fn(i) {
    list.range(0, map.size.1)
    |> list.map(fn(j) {
      case dict.get(map.blocks, #(i, j)) {
        Error(_) ->
          case map.robot == #(i, j) {
            False -> "."
            True -> "@"
          }
        Ok(Wall) -> "#"
        Ok(Box) -> "O"
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
}
