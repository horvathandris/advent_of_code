import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
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
  |> list.map(dfs(input, set.new(), _))
  |> list.fold(0, fn(acc, trail_peaks) { acc + set.size(trail_peaks) })
}

fn dfs(
  input: Map,
  locations_seen: Set(Location),
  last_node: #(Location, Int),
) -> Set(Location) {
  case last_node {
    #(last_location, 9) -> set.new() |> set.insert(last_location)
    _ ->
      get_valid_neighbours(input, last_node, locations_seen)
      |> list.fold(set.new(), fn(seen, neighbour) {
        dfs(input, set.insert(locations_seen, last_node.0), neighbour)
        |> set.union(seen)
      })
  }
}

fn get_valid_neighbours(
  input: Map,
  node: #(Location, Int),
  locations_seen: Set(Location),
) {
  [
    #(node.0.0 - 1, node.0.1),
    #(node.0.0, node.0.1 + 1),
    #(node.0.0 + 1, node.0.1),
    #(node.0.0, node.0.1 - 1),
  ]
  |> list.filter(fn(location) { !set.contains(locations_seen, location) })
  |> list.filter_map(fn(location) {
    case dict.get(input, location) {
      Ok(height) if height == node.1 + 1 -> Ok(#(location, height))
      _ -> Error(Nil)
    }
  })
}

pub fn pt_2(input: Map) -> Int {
  dict.filter(input, fn(_, height) { height == 0 })
  |> dict.to_list
  |> list.map(list.wrap)
  |> list.map(dfs_mod(input, _, set.new()))
  |> list.map(set.size)
  |> list.fold(0, int.add)
}

fn dfs_mod(
  input: Map,
  trail: List(#(Location, Int)),
  trails: Set(List(Location)),
) -> Set(List(Location)) {
  case trail {
    [#(_, 9), ..] ->
      list.map(trail, fn(node) { node.0 }) |> set.insert(trails, _)
    [last_node, ..] ->
      get_valid_neighbours(input, last_node, set.new())
      |> list.map(fn(node) { dfs_mod(input, [node, ..trail], trails) })
      |> list.fold(set.new(), set.union)

    // unreachable
    [] -> set.new()
  }
}
