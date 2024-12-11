import gleam/float
import gleam/int

pub fn parse_int(input: String) -> Int {
  let assert Ok(num) = int.parse(input)
  num
}

pub fn power(input: Int, exponent: Int) -> Int {
  let assert Ok(num) = int.power(input, int.to_float(exponent))
  float.round(num)
}
