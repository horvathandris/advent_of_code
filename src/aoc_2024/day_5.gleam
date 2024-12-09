import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import util

pub type Update =
  List(Int)

pub type Updates {
  Updates(rules: Dict(Int, List(Int)), updates: List(Update))
}

pub fn parse(input: String) -> Updates {
  let #(rules, updates) = split_once(input, "\n\n")
  let rules =
    string.split(rules, "\n")
    |> list.fold(dict.new(), fn(map, rule) {
      let #(a, b) = split_once(rule, "|")
      dict.get(map, util.parse_int(a))
      |> result.map(fn(existing) {
        dict.insert(map, util.parse_int(a), [util.parse_int(b), ..existing])
      })
      |> result.unwrap(dict.insert(map, util.parse_int(a), [util.parse_int(b)]))
    })
  let updates =
    string.split(updates, "\n")
    |> list.map(fn(update) {
      string.split(update, ",") |> list.map(util.parse_int)
    })

  Updates(rules:, updates:)
}

fn split_once(input: String, separator: String) -> #(String, String) {
  let assert Ok(split) = string.split_once(input, separator)
  split
}

pub fn pt_1(input: Updates) -> Int {
  list.filter(input.updates, check_rules(_, set.new(), input.rules))
  |> add_middle_numbers
}

fn add_middle_numbers(updates: List(List(Int))) {
  list.map(updates, fn(update) {
    let assert Ok(to_drop) =
      list.length(update)
      |> int.floor_divide(2)

    list.drop(update, to_drop)
    |> list.first
    |> result.unwrap(0)
  })
  |> list.fold(0, int.add)
}

fn check_rules(
  pages_to_check: List(Int),
  pages_seen: Set(Int),
  rules: Dict(Int, List(Int)),
) {
  case pages_to_check {
    [] -> True
    [page, ..tail] ->
      case
        dict.get(rules, page)
        |> result.unwrap([])
        |> list.all(fn(rule) {
          list.contains(tail, rule) || !set.contains(pages_seen, rule)
        })
      {
        True -> check_rules(tail, set.insert(pages_seen, page), rules)
        False -> False
      }
  }
}

pub fn pt_2(input: Updates) -> Int {
  list.filter(input.updates, fn(update) {
    !check_rules(update, set.new(), input.rules)
  })
  |> list.map(fn(update) {
    let relevant_rules =
      list.fold(update, input.rules, fn(acc, num) {
        dict.upsert(acc, num, fn(x) {
          case x {
            option.None -> []
            option.Some(y) -> y
          }
        })
      })
      |> dict.filter(fn(k, _) { list.contains(update, k) })
      |> dict.to_list
      |> list.map(fn(entry) {
        #(entry.0, list.filter(entry.1, list.contains(update, _)))
      })
      |> dict.from_list

    let no_incoming_edge_nodes =
      dict.filter(relevant_rules, fn(_, edges) { list.is_empty(edges) })
      |> dict.keys

    kahns_loop(no_incoming_edge_nodes, [], relevant_rules)
  })
  |> add_middle_numbers
}

fn kahns_loop(unseen: List(Int), sorted: List(Int), rules: Dict(Int, List(Int))) {
  case unseen {
    [] -> sorted
    [head, ..tail] -> {
      let updated_rules =
        dict.map_values(rules, fn(_, edges) {
          case list.contains(edges, head) {
            True -> list.filter(edges, fn(x) { x != head })
            False -> edges
          }
        })
        |> dict.filter(fn(k, _) { k != head })

      let to_see =
        dict.to_list(updated_rules)
        |> list.filter(fn(num_and_edges) { list.is_empty(num_and_edges.1) })
        |> list.map(fn(num_and_edges) { num_and_edges.0 })
        |> list.drop_while(fn(num) { list.contains(unseen, num) })

      kahns_loop(list.append(tail, to_see), [head, ..sorted], updated_rules)
    }
  }
}
