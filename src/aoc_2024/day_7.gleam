import gleam/int
import gleam/list
import gleam/string

pub type Equation {
  Equation(result: Int, numbers: List(Int))
}

type Operator {
  Plus
  Times
}

pub fn parse(input: String) -> List(Equation) {
  let lines = string.split(input, "\n")
  use line <- list.map(lines)
  let assert Ok(#(result, numbers)) = string.split_once(line, ": ")
  string.split(numbers, " ")
  |> list.map(parse_int)
  |> Equation(parse_int(result), _)
}

fn parse_int(input: String) -> Int {
  let assert Ok(num) = int.parse(input)
  num
}

pub fn pt_1(input: List(Equation)) -> Int {
  use accumulator, problem <- list.fold(input, 0)
  case solve_problem(problem) {
    True -> problem.result
    False -> 0
  }
  + accumulator
}

fn solve_problem(input: Equation) -> Bool {
  list.length(input.numbers)
  |> fn(length) { permutations_with_repetition([Plus, Times], length - 1) }
  |> list.count(fn(permutation) {
    let assert [head, ..tail] = input.numbers

    input.result
    == {
      use acc, num <- list.fold(tail, #(head, permutation))
      let assert [operator, ..remaining] = acc.1
      case operator {
        Plus -> #(acc.0 + num, remaining)
        Times -> #(acc.0 * num, remaining)
      }
    }.0
  })
  > 0
}

fn permutations_with_repetition(
  set: List(Operator),
  k: Int,
) -> List(List(Operator)) {
  case k {
    0 -> [[]]
    _ -> {
      let tuples_k_minus_1 = permutations_with_repetition(set, k - 1)
      use tuple <- list.flat_map(tuples_k_minus_1)
      list.map(set, fn(operator) { [operator, ..tuple] })
    }
  }
}

pub fn pt_2(input: List(Equation)) -> Int {
  todo as "part 2 not implemented"
}
