import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Rotation {
  Rotation(distance: Int)
}

pub fn parse(input: String) -> List(Rotation) {
  string.split(input, "\n")
  |> list.map(parse_line)
}

fn parse_line(input: String) -> Rotation {
  let assert Ok(result) = case input {
    "R" <> number ->
      int.parse(number)
      |> result.map(Rotation(distance: _))
    "L" <> number ->
      int.parse(number)
      |> result.map(int.negate)
      |> result.map(Rotation(distance: _))
    _ -> Error(Nil)
  }
  result
}

pub fn pt_1(input: List(Rotation)) -> Int {
  list.fold(input, #(50, 0), rotate).1
}

fn rotate(current: #(Int, Int), rotation: Rotation) -> #(Int, Int) {
  let assert Ok(new_current) = int.modulo(current.0 + rotation.distance, 100)
  case new_current == 0 {
    True -> #(new_current, current.1 + 1)
    False -> #(new_current, current.1)
  }
}

pub fn pt_2(input: List(Rotation)) -> Int {
  let #(_, result) =
    to_rotation_units(input)
    |> list.fold(#(50, 0), rotate)

  result
}

fn to_rotation_units(input: List(Rotation)) -> List(Rotation) {
  list.flat_map(input, fn(rotation) {
    case rotation.distance < 0 {
      True -> -1
      False -> 1
    }
    |> Rotation
    |> list.repeat(times: int.absolute_value(rotation.distance))
  })
}
