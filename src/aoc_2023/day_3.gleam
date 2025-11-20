import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import parallel_map

pub type Point {
  Point(x: Int, y: Int)
}

pub type Number {
  Number(value: Int, points: List(Point))
}

pub type RawNumber {
  RawNumber(value: String, points: List(Point))
}

pub type RawSchema {
  RawSchema(numbers: List(RawNumber), symbols: dict.Dict(Point, String))
}

pub type Schema {
  Schema(numbers: List(Number), symbols: dict.Dict(Point, String))
}

pub fn parse(input: String) -> Schema {
  let lines = string.split(input, "\n")

  list.index_fold(lines, RawSchema([], dict.new()), fn(acc, line, i) {
    string.split(line, "")
    |> consume_row(i, 0, RawNumber("", []), acc)
  })
  |> unraw_schema
}

fn consume_row(
  row: List(String),
  row_index: Int,
  col_index: Int,
  current_num: RawNumber,
  schema: RawSchema,
) -> RawSchema {
  let current_point = Point(row_index, col_index)
  case row {
    [] ->
      case current_num {
        RawNumber("", _) -> schema
        num -> RawSchema([num, ..schema.numbers], schema.symbols)
      }

    [".", ..rest] -> {
      let new_numbers = case current_num {
        RawNumber("", _) -> schema.numbers
        num -> [num, ..schema.numbers]
      }
      let new_schema = RawSchema(..schema, numbers: new_numbers)
      consume_row(rest, row_index, col_index + 1, RawNumber("", []), new_schema)
    }
    [x, ..rest]
      if x == "0"
      || x == "1"
      || x == "2"
      || x == "3"
      || x == "4"
      || x == "5"
      || x == "6"
      || x == "7"
      || x == "8"
      || x == "9"
    ->
      consume_row(
        rest,
        row_index,
        col_index + 1,
        RawNumber(current_num.value <> x, [current_point, ..current_num.points]),
        schema,
      )
    [symbol, ..rest] -> {
      let new_numbers = case current_num {
        RawNumber("", _) -> schema.numbers
        num -> [num, ..schema.numbers]
      }
      let new_schema =
        RawSchema(
          numbers: new_numbers,
          symbols: dict.insert(
            schema.symbols,
            Point(row_index, col_index),
            symbol,
          ),
        )
      consume_row(rest, row_index, col_index + 1, RawNumber("", []), new_schema)
    }
  }
}

fn unraw_schema(input: RawSchema) -> Schema {
  Schema(numbers: list.map(input.numbers, unraw_number), symbols: input.symbols)
}

fn unraw_number(input: RawNumber) -> Number {
  let assert Ok(num) = int.parse(input.value)
  Number(num, input.points)
}

pub fn pt_1(input: Schema) -> Int {
  use sum, number <- list.fold(input.numbers, 0)

  let adjacent_points =
    get_adjacent_points_for_number(number)
    |> set.to_list

  let has_symbol_adjacent =
    check_adjacent_points(adjacent_points, input.symbols)

  case has_symbol_adjacent {
    True -> sum + number.value
    False -> sum
  }
}

fn check_adjacent_points(
  adjacent_points: List(Point),
  symbols: dict.Dict(Point, String),
) -> Bool {
  use _, point <- list.fold_until(adjacent_points, False)
  case dict.get(symbols, point) {
    Ok(_) -> list.Stop(True)
    Error(_) -> list.Continue(False)
  }
}

fn get_adjacent_points_for_number(number: Number) {
  use acc, point <- list.fold(number.points, set.new())
  get_adjacent_points(point)
  |> set.from_list
  |> set.union(acc)
}

fn get_adjacent_points(point: Point) {
  [
    Point(point.x - 1, point.y - 1),
    Point(point.x - 1, point.y),
    Point(point.x - 1, point.y + 1),
    Point(point.x, point.y - 1),
    Point(point.x, point.y + 1),
    Point(point.x + 1, point.y - 1),
    Point(point.x + 1, point.y),
    Point(point.x + 1, point.y + 1),
  ]
}

pub fn pt_2(input: Schema) {
  todo as "part 2 not implemented"
}
