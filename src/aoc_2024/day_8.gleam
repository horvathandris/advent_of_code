import common.{type Location}
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string

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
      find_antinodes(pair.0, pair.1, input.size)
      |> set.union(acc)
    })
    |> set.union(top_acc)
  })
  |> set.size
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
  dict.values(input.antennas)
  |> list.fold(set.new(), fn(top_acc, locations) {
    list.combination_pairs(locations)
    |> list.fold(set.new(), fn(acc, pair) {
      find_antinodes_loop(pair.0, pair.1, input.size)
      |> set.union(acc)
    })
    |> set.union(top_acc)
  })
  |> set.size
}

fn find_antinodes_loop(
  location1: Location,
  location2: Location,
  size: Int,
) -> Set(Location) {
  let dist = calc_dist(location1, location2)

  let antinodes1 = get_antinodes(location2, dist, size)
  let antinodes2 = negate_dist(dist) |> get_antinodes(location1, _, size)

  set.union(antinodes1, antinodes2)
}

fn get_antinodes(
  location: Location,
  dist: #(Int, Int),
  size: Int,
) -> Set(Location) {
  case
    apply_dist(location, dist)
    |> validate_location(size)
  {
    Ok(antinode) -> get_antinodes(antinode, dist, size)
    _ -> set.new()
  }
  |> set.insert(location)
}

fn find_antinodes(
  location1: Location,
  location2: Location,
  size: Int,
) -> Set(Location) {
  let dist = calc_dist(location1, location2)

  let antinode1 =
    apply_dist(location2, dist)
    |> validate_location(size)

  let antinode2 =
    negate_dist(dist)
    |> apply_dist(location1, _)
    |> validate_location(size)

  [antinode1, antinode2]
  |> result.values
  |> set.from_list
}
