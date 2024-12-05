import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

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
      dict.get(map, parse_int(a))
      |> result.map(fn(existing) {
        dict.insert(map, parse_int(a), [parse_int(b), ..existing])
      })
      |> result.unwrap(dict.insert(map, parse_int(a), [parse_int(b)]))
    })
  let updates =
    string.split(updates, "\n")
    |> list.map(fn(update) { string.split(update, ",") |> list.map(parse_int) })

  Updates(rules:, updates:)
}

fn split_once(input: String, separator: String) -> #(String, String) {
  let assert Ok(split) = string.split_once(input, separator)
  split
}

fn parse_int(input: String) -> Int {
  let assert Ok(int) = int.parse(input)
  int
}

pub fn pt_1(input: Updates) {
  let valid_updates =
    list.filter(input.updates, check_rules(_, set.new(), input.rules))

  list.map(valid_updates, fn(update) {
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
  pages_seen: set.Set(Int),
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

pub fn pt_2(input: Updates) {
  todo as "part 2 not implemented"
}
