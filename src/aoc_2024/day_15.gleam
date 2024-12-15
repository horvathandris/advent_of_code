import common.{type Direction, type Location, East, North, South, West}
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import util

pub type Block {
  Wall
  Box
}

pub type Map {
  Map(blocks: Dict(Location, Block), robot: Location)
}

pub fn parse(input: String) -> #(Map, List(Direction)) {
  let #(map, moves) = util.split_once(input, "\n\n")
  #(parse_map(map), parse_moves(moves))
}

fn parse_map(input: String) -> Map {
  use acc, line, i <- list.index_fold(
    string.split(input, "\n"),
    Map(dict.new(), #(0, 0)),
  )
  use inner_acc, char, j <- list.index_fold(string.split(line, ""), acc)
  case char {
    "#" -> Map(dict.insert(inner_acc.blocks, #(i, j), Wall), inner_acc.robot)
    "O" -> Map(dict.insert(inner_acc.blocks, #(i, j), Box), inner_acc.robot)
    "@" -> Map(inner_acc.blocks, #(i, j))
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
  io.debug(input)
  todo as "part 1 not implemented"
}

pub fn pt_2(input: #(Map, List(Direction))) -> Int {
  todo as "part 2 not implemented"
}
