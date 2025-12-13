import common
import gleam/dict
import gleam/list
import gleam/result
import gleam/set
import gleam/string

pub type Diagram {
  Diagram(
    start: common.Location,
    splitters: set.Set(common.Location),
    height: Int,
  )
}

type Progress {
  Progress(diagram: Diagram, beams: set.Set(common.Location), split_count: Int)
}

type AdvancedProgress {
  AdvancedProgress(
    diagram: Diagram,
    beams: List(common.Location),
    split_count: Int,
  )
}

pub fn parse(input: String) -> Diagram {
  use acc, line, row <- list.index_fold(
    string.split(input, "\n"),
    Diagram(#(0, 0), set.new(), 0),
  )
  use inner_acc, char, column <- list.index_fold(string.split(line, ""), acc)

  case char {
    "S" -> Diagram(..inner_acc, start: #(row, column), height: row + 1)
    "^" ->
      Diagram(
        ..inner_acc,
        splitters: set.insert(inner_acc.splitters, #(row, column)),
        height: row + 1,
      )
    _ -> Diagram(..inner_acc, height: row + 1)
  }
}

pub fn pt_1(input: Diagram) -> Int {
  Progress(input, set.from_list([input.start]), 0)
  |> extend_to_end
  |> fn(result) { result.split_count }
}

fn extend_to_end(input: Progress) {
  let progress = extend_beam(input)
  case set.is_empty(progress.beams) {
    True -> progress
    False -> extend_to_end(progress)
  }
}

fn extend_beam(input: Progress) -> Progress {
  set.fold(input.beams, Progress(..input, beams: set.new()), fn(acc, location) {
    next_location(location, input.diagram.height)
    |> result.map(fn(next) {
      case set.contains(input.diagram.splitters, next) {
        True ->
          Progress(
            ..acc,
            beams: split_beam(next) |> set.union(acc.beams),
            split_count: acc.split_count + 1,
          )
        False -> Progress(..acc, beams: set.insert(acc.beams, next))
      }
    })
    |> result.unwrap(acc)
  })
}

fn next_location(
  location: common.Location,
  max_height: Int,
) -> Result(common.Location, Nil) {
  let #(row, column) = location
  case row + 1 < max_height {
    True -> Ok(#(row + 1, column))
    False -> Error(Nil)
  }
}

fn split_beam(location: common.Location) -> set.Set(common.Location) {
  let #(row, column) = location
  [#(row, column - 1), #(row, column + 1)]
  |> set.from_list
}

pub fn pt_2(input: Diagram) -> Int {
  todo as "need to parse as a tree, and BFS"
}
