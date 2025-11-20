import gleam/dict
import gleam/io
import gleam/list
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

pub type Number {
  Number(value: Int, positions: List(Point))
}

pub type RawNumber {
  RawNumber(value: String, positions: List(Point))
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
    |> consume_row(i, 0, "", acc)
    |> io.debug
  })
  |> todo
}

fn consume_row(
  row: List(String),
  row_index: Int,
  col_index: Int,
  current_num: #(String, List(Point)),
  schema: RawSchema,
) -> RawSchema {
  case row {
    [] -> schema
    [".", ..rest] -> {
      let new_numbers = case current_num {
        #("", _) -> schema.numbers
        #(num, points) -> [current_num, ..schema.numbers]
      }
      let new_schema = RawSchema(..schema, numbers: new_numbers)
      consume_row(rest, row_index, col_index + 1, "", new_schema)
    }
    ["1", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "1", schema)
    ["2", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "2", schema)
    ["3", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "3", schema)
    ["4", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "4", schema)
    ["5", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "5", schema)
    ["6", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "6", schema)
    ["7", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "7", schema)
    ["8", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "8", schema)
    ["9", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "9", schema)
    ["0", ..rest] ->
      consume_row(rest, row_index, col_index + 1, current_num <> "0", schema)
    [symbol, ..rest] -> {
      let new_numbers = case current_num {
        "" -> schema.numbers
        _ -> [current_num, ..schema.numbers]
      }
      let new_schema =
        RawSchema(
          new_numbers,
          dict.insert(schema.symbols, Point(row_index, col_index), symbol),
        )
      consume_row(rest, row_index, col_index + 1, "", new_schema)
    }
  }
}

pub fn pt_1(input: Schema) {
  todo as "part 1 not implemented"
}

pub fn pt_2(input: Schema) {
  todo as "part 2 not implemented"
}
