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

pub fn pt_1(input: Map) -> Int {
  dict.filter(input, fn(_, height) { height == 0 })
  |> dict.to_list
  |> list.map(fn(start_node) { [start_node] })
  |> dfs(input, _, [])
  |> list.length
}

fn dfs(
  input: Map,
  incomplete_paths: List(List(#(Location, Int))),
  complete_paths: List(List(#(Location, Int))),
) -> List(List(#(Location, Int))) {
  case incomplete_paths {
    [] -> complete_paths
    [head, ..tail] -> todo
  }
}

pub fn pt_2(input: Map) -> Int {
  todo as "part 2 not implemented"
}
