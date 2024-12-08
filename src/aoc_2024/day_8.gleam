import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

pub type Location =
  #(Int, Int)

pub type Map {
  Map(antennas: Dict(String, List(Location)), size: Int)
}

pub fn parse(input: String) -> Map {
  let lines = string.split(input, "\n")
  let size = list.length(lines)

  list.index_map(lines, fn(line, i) {
    string.split(line, "")
    |> list.index_fold(dict.new(), fn(acc, char, j) {
      case char {
        "." -> acc
        antenna ->
          dict.upsert(acc, antenna, fn(locations) {
            case locations {
              None -> [#(i, j)]
              Some(locations) -> [#(i, j), ..locations]
            }
          })
      }
    })
  })
  |> list.fold(dict.new(), fn(acc, antenna) {
    dict.combine(acc, antenna, list.append)
  })
  |> Map(size)
}

pub fn pt_1(input: Map) {
  dict.values(input.antennas)
  |> list.fold(set.new(), fn(top_acc, locations) {
    list.combination_pairs(locations)
    |> list.fold(set.new(), fn(acc, pair) {
      let dist = calc_dist(pair.0, pair.1)

      let antinode1 =
        apply_dist(pair.1, dist)
        |> validate_location(input.size)

      let antinode2 =
        negate_dist(dist)
        |> apply_dist(pair.0, _)
        |> validate_location(input.size)

      acc
      |> insert_if_valid(antinode1)
      |> insert_if_valid(antinode2)
    })
    |> set.union(top_acc)
  })
  |> set.size
}

fn insert_if_valid(
  s: Set(Location),
  location: Result(Location, Nil),
) -> Set(Location) {
  case location {
    Ok(loc) -> set.insert(s, loc)
    _ -> s
  }
}

fn validate_location(location: Location, size: Int) {
  case
    location.0 < size && location.1 < size && location.0 >= 0 && location.1 >= 0
  {
    False -> Error(Nil)
    True -> Ok(location)
  }
}

fn apply_dist(location: Location, dist: #(Int, Int)) -> Location {
  #(location.0 + dist.0, location.1 + dist.1)
}

fn calc_dist(location1: Location, location2: Location) -> #(Int, Int) {
  #(location2.0 - location1.0, location2.1 - location1.1)
}

fn negate_dist(distance: #(Int, Int)) {
  #(-distance.0, -distance.1)
}

pub fn pt_2(input: Map) {
  todo as "part 2 not implemented"
}
