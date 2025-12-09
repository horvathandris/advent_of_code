import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type ParsedInput {
  ParsedInput(ranges: List(Range), ingredients: List(Int))
}

pub type Range {
  Range(start: Int, end: Int)
}

pub fn parse(input: String) -> ParsedInput {
  string.split(input, "\n")
  |> list.fold(#(ParsedInput([], []), False), fn(acc, line) {
    case acc.1 {
      False ->
        case line {
          "" -> #(acc.0, True)
          _ -> {
            let assert Ok(#(start, end)) = string.split_once(line, "-")
            let assert Ok(start) = int.parse(start)
            let assert Ok(end) = int.parse(end)
            #(
              ParsedInput(..acc.0, ranges: [
                Range(start, end),
                ..{ acc.0 }.ranges
              ]),
              False,
            )
          }
        }
      True ->
        int.parse(line)
        |> result.unwrap(0)
        |> fn(id) {
          #(
            ParsedInput(..acc.0, ingredients: [id, ..{ acc.0 }.ingredients]),
            True,
          )
        }
    }
  })
  |> fn(x) { x.0 }
}

pub fn pt_1(input: ParsedInput) {
  let ranges = merge_ranges(input.ranges)
  use sum, ingredient <- list.fold(input.ingredients, 0)
  case list.any(ranges, in_range(_, ingredient)) {
    True -> sum + 1
    False -> sum
  }
}

fn in_range(range: Range, ingredient: Int) -> Bool {
  ingredient >= range.start && ingredient <= range.end
}

pub fn pt_2(input: ParsedInput) {
  use sum, range <- list.fold(merge_ranges(input.ranges), 0)

  sum + range.end - range.start + 1
}

fn merge_ranges(ranges: List(Range)) -> List(Range) {
  list.sort(ranges, by: fn(a, b) { int.compare(a.start, b.start) })
  |> list.fold([], fn(acc: List(Range), range: Range) {
    case acc {
      [] -> [range]
      _ -> {
        let assert [last_range, ..rest] = acc
        case range.start <= last_range.end {
          True -> [merge(range, last_range), ..rest]
          False -> [range, last_range, ..rest]
        }
      }
    }
  })
}

fn merge(a: Range, b: Range) -> Range {
  Range(start: int.min(a.start, b.start), end: int.max(a.end, b.end))
}
