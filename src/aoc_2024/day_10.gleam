import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util

pub type Location =
  #(Int, Int)

pub type Map =
  Dict(Location, Int)

pub fn parse(input: String) -> Map {
  string.split(input, "\n")
  |> list.index_map(fn(line, i) {
    string.split(line, "")
    |> list.index_fold(dict.new(), fn(acc, height, j) {
      dict.insert(acc, #(i, j), util.parse_int(height))
    })
  })
  |> list.reduce(dict.merge)
  |> result.lazy_unwrap(dict.new)
}

pub fn pt_1(input: Map) {
  todo as "part 1 not implemented"
}

pub fn pt_2(input: Map) {
  todo as "part 2 not implemented"
}
