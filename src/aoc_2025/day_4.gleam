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
  case can_be_removed(position, input) {
    True -> #(set.delete(current_map, position), removed_count + 1)
    False -> #(current_map, removed_count)
  }
}

fn can_be_removed(position: Position, map: Map) -> Bool {
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
  |> list.fold_until(#(0, True), fn(acc, adjacent_position) {
    case set.contains(map, adjacent_position) {
      True ->
        case acc.0 >= 3 {
          True -> list.Stop(#(0, False))
          False -> list.Continue(#(acc.0 + 1, True))
        }
      False -> list.Continue(acc)
    }
  })
  |> fn(result) { result.1 }
}
