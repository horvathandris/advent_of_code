import gleam/int
import gleam/list
import gleam/set
import gleam/string

pub type Position =
  #(Int, Int)

pub type Map =
  set.Set(Position)

pub fn parse(input: String) -> Map {
  use map, line, i <- list.index_fold(string.split(input, "\n"), set.new())
  use inner_map, character, j <- list.index_fold(string.split(line, ""), map)

  case character {
    "@" -> set.insert(inner_map, #(i, j))
    _ -> inner_map
  }
}

pub fn pt_1(input: Map) -> Int {
  remove_rolls(input).1
}

fn count_adjacent_rolls(position: Position, map: Map) {
  [
    #(position.0 - 1, position.1 - 1),
    #(position.0 - 1, position.1),
    #(position.0 - 1, position.1 + 1),
    #(position.0, position.1 + 1),
    #(position.0 + 1, position.1 + 1),
    #(position.0 + 1, position.1),
    #(position.0 + 1, position.1 - 1),
    #(position.0, position.1 - 1),
  ]
  |> list.map(fn(adjacent_position) {
    case set.contains(map, adjacent_position) {
      True -> 1
      False -> 0
    }
  })
  |> int.sum
}

pub fn pt_2(input: Map) -> Int {
  remove_rolls_while_can(input, 0)
}

fn remove_rolls_while_can(input: Map, current_removed_count: Int) -> Int {
  let #(new_map, removed_count) = remove_rolls(input)
  case removed_count {
    0 -> current_removed_count
    x -> remove_rolls_while_can(new_map, current_removed_count + x)
  }
}

fn remove_rolls(input: Map) -> #(Map, Int) {
  use #(current_map, removed_count), position <- list.fold(
    set.to_list(input),
    #(input, 0),
  )
  case count_adjacent_rolls(position, input) {
    x if x < 4 -> #(set.delete(current_map, position), removed_count + 1)
    _ -> #(current_map, removed_count)
  }
}
