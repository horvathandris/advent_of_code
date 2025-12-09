import gleam/function
import gleam/int
import gleam/list
import gleam/string

pub type Problem {
  Add(elements: List(Int))
  Multiply(elements: List(Int))
}

pub fn parse(input: String) -> List(Problem) {
  let lines =
    string.split(input, "\n")
    |> list.map(fn(line) {
      string.split(line, " ")
      |> list.map(string.trim)
      |> list.filter(fn(s) { !string.is_empty(s) })
    })

  let assert [operands, ..elements] = list.reverse(lines)
  let elements = list.transpose(elements)

  list.map2(operands, elements, fn(operand, element_row) {
    let numbers = list.filter_map(element_row, int.parse)
    case operand {
      "+" -> Ok(Add(numbers))
      "*" -> Ok(Multiply(numbers))
      _ -> Error(Nil)
    }
  })
  |> list.filter_map(function.identity)
}

pub fn pt_1(input: List(Problem)) -> Int {
  use sum, problem <- list.fold(input, 0)
  sum + solve(problem)
}

fn solve(problem: Problem) {
  case problem {
    Add(elements:) -> int.sum(elements)
    Multiply(elements:) -> int.product(elements)
  }
}

pub fn pt_2(input: List(Problem)) -> Int {
  todo as "part 2 not implemented"
}
