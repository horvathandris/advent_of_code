import gleam/function
import gleam/int
import gleam/list
import gleam/string

pub type Problem {
  Add(elements: List(Int))
  Multiply(elements: List(Int))
}

pub fn parse(input: String) -> List(String) {
  string.split(input, "\n")
}

pub fn pt_1(input: List(String)) -> Int {
  let lines =
    list.map(input, fn(line) {
      string.split(line, " ")
      |> list.map(string.trim)
      |> list.filter(fn(s) { !string.is_empty(s) })
    })

  let assert [operands, ..elements] = list.reverse(lines)
  let elements = list.transpose(elements)

  let problems =
    list.map2(operands, elements, fn(operand, element_row) {
      let numbers = list.filter_map(element_row, int.parse)
      case operand {
        "+" -> Ok(Add(numbers))
        "*" -> Ok(Multiply(numbers))
        _ -> Error(Nil)
      }
    })
    |> list.filter_map(function.identity)

  use sum, problem <- list.fold(problems, 0)
  sum + solve(problem)
}

fn solve(problem: Problem) -> Int {
  case problem {
    Add(elements:) -> int.sum(elements)
    Multiply(elements:) -> int.product(elements)
  }
}

pub fn pt_2(input: List(String)) -> Int {
  let assert [operands, ..elements] =
    list.reverse(input)
    |> list.map(string.split(_, ""))

  let operands =
    list.map(operands, string.trim)
    |> list.filter(fn(s) { !string.is_empty(s) })
    |> list.reverse

  let numbers =
    list.transpose(elements)
    |> list.fold([[]], fn(acc, column) {
      let joined =
        list.reverse(column)
        |> string.join("")
        |> string.trim

      case joined {
        "" -> [[], ..acc]
        _ -> {
          let assert Ok(number) = int.parse(joined)
          let assert [head, ..tail] = acc
          [[number, ..head], ..tail]
        }
      }
    })

  let problems =
    list.map2(operands, numbers, fn(operand, number_row) {
      case operand {
        "+" -> Ok(Add(number_row))
        "*" -> Ok(Multiply(number_row))
        _ -> Error(Nil)
      }
    })
    |> list.filter_map(function.identity)

  use sum, problem <- list.fold(problems, 0)
  sum + solve(problem)
}
