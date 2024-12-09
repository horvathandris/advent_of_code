import gleam/int
import gleam/list
import gleam/string
import util

pub type ParsedInput =
  #(List(Int), List(Int))

pub fn parse(input: String) -> ParsedInput {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let assert Ok(#(left, right)) = string.split_once(line, "   ")
    #(util.parse_int(left), util.parse_int(right))
  })
  |> list.unzip
}

pub fn pt_1(input: ParsedInput) -> Int {
  let sort_list = list.sort(_, int.compare)
  list.map2(sort_list(input.0), sort_list(input.1), fn(left, right) {
    int.absolute_value(left - right)
  })
  |> list.fold(0, int.add)
}

pub fn pt_2(input: ParsedInput) -> Int {
  list.map(input.0, fn(left) {
    list.filter(input.1, fn(right) { left == right })
    |> list.length
    |> int.multiply(left)
  })
  |> list.fold(0, int.add)
}
