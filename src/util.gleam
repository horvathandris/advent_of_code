import gleam/int

pub fn parse_int(input: String) -> Int {
  let assert Ok(num) = int.parse(input)
  num
}
