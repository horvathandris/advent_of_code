import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
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
  io.debug(input)
  todo as "part 1 not implemented"
}

pub fn pt_2(input: Updates) {
  todo as "part 2 not implemented"
}
