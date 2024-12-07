import gleam/int
import gleam/list
import gleam/result
import gleam/string
import parallel_map

pub type Equation {
  Equation(result: Int, numbers: List(Int))
}

type Operator {
  Plus
  Times
  Concat
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
  case solve_problem(problem, [Plus, Times]) {
    True -> problem.result
    False -> 0
  }
  + accumulator
}

fn solve_problem(input: Equation, operators: List(Operator)) -> Bool {
  // todo: this count should be a fold_until that stops when first True is reached
  list.length(input.numbers)
  |> fn(length) { permutations_with_repetition(operators, length - 1) }
  |> list.fold_until(False, fn(_, permutation) {
    let assert [head, ..tail] = input.numbers

    let is_solution =
      input.result
      == {
        list.fold_until(tail, #(head, permutation), fn(acc, num) {
          case head > input.result {
            True -> list.Stop(acc)
            False -> {
              let assert [operator, ..remaining] = acc.1
              case operator {
                Plus -> #(acc.0 + num, remaining)
                Times -> #(acc.0 * num, remaining)
                Concat -> #(
                  parse_int(int.to_string(acc.0) <> int.to_string(num)),
                  remaining,
                )
              }
              |> list.Continue
            }
          }
        })
      }.0

    case is_solution {
      True -> list.Stop(True)
      False -> list.Continue(False)
    }
  })
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
  let fun = fn(problem) {
    case solve_problem(problem, [Concat, Times, Plus]) {
      True -> problem.result
      False -> 0
    }
  }

  parallel_map.list_pmap(
    input,
    fun,
    parallel_map.MatchSchedulersOnline,
    100_000,
  )
  |> list.map(result.unwrap(_, 0))
  |> list.fold(0, int.add)
}
