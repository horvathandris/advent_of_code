import common.{type Location}
import gleam/io
import gleam/list
import gleam/string
import util

pub type Robot {
  Robot(position: Location, velocity: #(Int, Int))
}

pub fn parse(input: String) -> List(Robot) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let #(position, velocity) = util.split_once(line, " ")
    Robot(parse_attribute(position), parse_attribute(velocity))
  })
}

fn parse_attribute(input: String) -> #(Int, Int) {
  let #(_, attribute) = util.split_once(input, "=")
  let #(x, y) = util.split_once(attribute, ",")
  #(util.parse_int(x), util.parse_int(y))
}

pub fn pt_1(input: List(Robot)) -> Int {
  todo as "part 1 not implemented"
}

pub fn pt_2(input: List(Robot)) -> Int {
  todo as "part 2 not implemented"
}
