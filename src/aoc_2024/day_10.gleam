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
  io.println("")
  io.println("incomplete: " <> string.inspect(incomplete_paths))
  io.println("  complete: " <> string.inspect(complete_paths))
  case incomplete_paths {
    [] -> complete_paths
    [incomplete_path, ..rest] -> {
      let assert [last_location, ..nodes] = incomplete_path

      get_neighbours(last_location.0)
      |> list.filter_map(fn(neighbour) {
        case dict.get(input, neighbour) {
          Ok(height) if height == last_location.1 + 1 ->
            Ok(#(neighbour, height))
          _ -> Error(Nil)
        }
      })
      |> io.debug
      |> list.flat_map(fn(neighbour) {
        case neighbour {
          #(_, 9) ->
            dfs(input, rest, [
              [neighbour, last_location, ..nodes],
              ..complete_paths
            ])
          _ ->
            dfs(
              input,
              [[neighbour, last_location, ..nodes], ..rest],
              complete_paths,
            )
        }
      })
      |> list.append(complete_paths)
    }
  }
}

fn get_neighbours(location: Location) {
  [
    #(location.0 - 1, location.1),
    #(location.0, location.1 + 1),
    #(location.0 + 1, location.1),
    #(location.0, location.1 - 1),
  ]
}

pub fn pt_2(input: Map) -> Int {
  todo as "part 2 not implemented"
}
