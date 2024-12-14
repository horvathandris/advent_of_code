import gleam/float
import gleam/int
import gleam/string

pub fn parse_int(input: String) -> Int {
  let assert Ok(num) = int.parse(input)
  num
}

pub fn power(input: Int, exponent: Int) -> Int {
  let assert Ok(num) = int.power(input, int.to_float(exponent))
  float.round(num)
}

pub fn split_once(input: String, separator: String) -> #(String, String) {
  let assert Ok(#(a, b)) = string.split_once(input, separator)
  #(a, b)
}
