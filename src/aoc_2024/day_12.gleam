import common.{type Location}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Map =
  dict.Dict(Location, String)

type Region {
  Region(plants: Set(Location), perimeter: Int)
}

pub fn parse(input: String) -> Map {
  string.split(input, "\n")
  |> list.index_fold(dict.new(), fn(map, line, i) {
    string.split(line, "")
    |> list.index_fold(dict.new(), fn(acc, plant, j) {
      dict.insert(acc, #(i, j), plant)
    })
    |> dict.merge(map)
  })
}

pub fn pt_1(input: Map) -> Int {
  find_regions(dict.keys(input) |> set.from_list, [], input)
  |> list.map(fn(region) { set.size(region.plants) * region.perimeter })
  |> list.fold(0, int.add)
}

fn find_regions(
  unseen: Set(Location),
  regions: List(Region),
  map: Map,
) -> List(Region) {
  case set.to_list(unseen) {
    [] -> regions
    [seed, ..] -> {
      let region =
        grow_region(seed, map, Region(set.new() |> set.insert(seed), 0))
      let unseen = set.difference(unseen, region.plants)
      find_regions(unseen, [region, ..regions], map)
    }
  }
}

fn grow_region(origin: Location, map: Map, region: Region) -> Region {
  let assert Ok(plant) = dict.get(map, origin)
  let #(additional_perimeter, valid_neighbours) =
    get_valid_neighours(origin, plant, map, region)

  list.fold(
    valid_neighbours,
    Region(
      list.fold(valid_neighbours, region.plants, set.insert),
      region.perimeter + additional_perimeter,
    ),
    fn(acc, neighbour) { grow_region(neighbour, map, acc) },
  )
}

fn get_valid_neighours(
  location: Location,
  plant: String,
  map: Map,
  region: Region,
) -> #(Int, List(Location)) {
  let result =
    [
      #(location.0, location.1 + 1),
      #(location.0 + 1, location.1),
      #(location.0, location.1 - 1),
      #(location.0 - 1, location.1),
    ]
    |> list.map_fold(0, fn(acc, neighbour) {
      case set.contains(region.plants, neighbour) {
        False ->
          case dict.get(map, neighbour) {
            Ok(neighbour_flower) if neighbour_flower == plant -> #(
              acc,
              Ok(neighbour),
            )
            _ -> #(acc + 1, Error(Nil))
          }
        _ -> #(acc, Error(Nil))
      }
    })

  #(result.0, list.filter_map(result.1, fn(x) { x }))
}

pub fn pt_2(input: Map) -> Int {
  find_regions(dict.keys(input) |> set.from_list, [], input)
  |> list.map(fn(region) { region.plants })
  |> list.map(fn(plants) { set.size(plants) * count_corners(plants) })
  |> list.fold(0, int.add)
}

fn count_corners(plants: Set(Location)) -> Int {
  let concave_corners =
    set.fold(plants, 0, fn(acc1, location) {
      [
        // top right concave
        #([#(location.0 - 1, location.1), #(location.0, location.1 + 1)], #(
          location.0 - 1,
          location.1 + 1,
        )),
        // bottom right concave
        #([#(location.0, location.1 + 1), #(location.0 + 1, location.1)], #(
          location.0 + 1,
          location.1 + 1,
        )),
        // bottom left concave
        #([#(location.0 + 1, location.1), #(location.0, location.1 - 1)], #(
          location.0 + 1,
          location.1 - 1,
        )),
        // top left concave
        #([#(location.0, location.1 - 1), #(location.0 - 1, location.1)], #(
          location.0 - 1,
          location.1 - 1,
        )),
      ]
      |> list.fold(0, fn(acc2, possible_corner) {
        {
          list.all(possible_corner.0, set.contains(plants, _))
          && !set.contains(plants, possible_corner.1)
        }
        |> bool.to_int
        |> int.add(acc2)
      })
      |> int.add(acc1)
    })

  let convex_corners =
    set.fold(plants, 0, fn(acc1, location) {
      [
        // top right convex
        [#(location.0 - 1, location.1), #(location.0, location.1 + 1)],
        // bottom right convex
        [#(location.0, location.1 + 1), #(location.0 + 1, location.1)],
        // bottom left convex
        [#(location.0 + 1, location.1), #(location.0, location.1 - 1)],
        // top left convex
        [#(location.0, location.1 - 1), #(location.0 - 1, location.1)],
      ]
      |> list.fold(0, fn(acc2, possible_corner) {
        !list.any(possible_corner, set.contains(plants, _))
        |> bool.to_int
        |> int.add(acc2)
      })
      |> int.add(acc1)
    })

  concave_corners + convex_corners
}
