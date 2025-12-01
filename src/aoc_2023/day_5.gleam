import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import parallel_map

pub type Range =
  #(Int, Int)

pub type DynamicRange =
  #(Int, Int)

pub type Almanac {
  Almanac(initial: List(Int), maps: List(dict.Dict(Range, Int)))
}

pub type Pt2Almanac {
  Pt2Almanac(initial: List(DynamicRange), maps: List(dict.Dict(Range, Int)))
}

fn to_pt2_almanac(input: Almanac) -> Pt2Almanac {
  let initial =
    list.sized_chunk(input.initial, 2)
    |> list.map(fn(range) {
      let assert [start, length] = range
      #(start, length)
    })
  Pt2Almanac(initial:, maps: input.maps)
}

pub fn parse(input: String) -> Almanac {
  let lines = string.split(input, "\n")
  let assert [initial, ..rest] = lines
  let assert Ok(#(_, initial)) = string.split_once(initial, ":")
  let assert Ok(initial) =
    string.trim(initial)
    |> string.split(" ")
    |> list.map(string.trim)
    |> list.try_map(int.parse)

  let maps =
    parse_rest(rest, False, [])
    |> list.reverse

  Almanac(initial, maps)
}

fn parse_rest(
  input: List(String),
  is_header: Bool,
  acc: List(dict.Dict(Range, Int)),
) -> List(dict.Dict(Range, Int)) {
  case input {
    [] -> acc
    ["", ..rest] -> parse_rest(rest, True, acc)
    [_, ..rest] if is_header -> parse_rest(rest, False, [dict.new(), ..acc])
    [mapping, ..rest] -> {
      let assert Ok([destination_range_start, source_range_start, range_length]) =
        string.trim(mapping)
        |> string.split(" ")
        |> list.try_map(int.parse)

      let source_range = #(
        source_range_start,
        source_range_start + range_length - 1,
      )

      let assert [current_mapping, ..other_mappings] = acc

      let new_current_mapping =
        dict.insert(current_mapping, source_range, destination_range_start)

      parse_rest(rest, False, [new_current_mapping, ..other_mappings])
    }
  }
}

pub fn pt_1(input: Almanac) {
  input.initial
  |> list.map(find_end(_, input.maps))
  |> list.reduce(int.min)
  |> result.unwrap(0)
}

fn find_end(input: Int, maps: List(dict.Dict(Range, Int))) -> Int {
  use number, mapping <- list.fold(maps, input)
  dict.to_list(mapping)
  |> list.find_map(fn(ranges) {
    let #(source, destination) = ranges
    case source.0 <= number && number <= source.1 {
      False -> Error(Nil)
      True -> Ok(destination + number - source.0)
    }
  })
  |> result.unwrap(number)
}

pub fn pt_2(input: Almanac) {
  todo
  let input = to_pt2_almanac(input)

  let assert [first, ..rest] = input.initial

  let mapped_first_of_first = find_end(first.0, input.maps)

  use acc, range <- list.fold(
    [#(first.0 + 1, first.1 - 1), ..rest],
    mapped_first_of_first,
  )

  list.range(range.0, range.0 + range.1 - 1)
  |> list.fold(acc, fn(inner_acc, num) {
    let current_mapped = find_end(num, input.maps)
    int.min(current_mapped, inner_acc)
  })
  |> int.min(acc)
}
