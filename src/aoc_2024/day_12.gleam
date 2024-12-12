import gleam/dict
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Location =
  #(Int, Int)

pub type Map =
  dict.Dict(Location, String)

type Region {
  Region(plants: Set(Location), perimeter: Int)
}

pub fn parse(input: String) -> Map {
  string.split(input, "\n")
  |> list.index_fold(dict.new(), fn(map, line, i) {
    string.split(line, "")
    |> list.index_fold(dict.new(), fn(acc, plant, j) {
      dict.insert(acc, #(i, j), plant)
    })
    |> dict.merge(map)
  })
}

pub fn pt_1(input: Map) -> Int {
  // region growing, with each region added, recalc perimeter, and area (just add 1)
  io.debug(input)
  todo as "part 1 not implemented"
}

pub fn pt_2(input: Map) -> Int {
  todo as "part 2 not implemented"
}
