import gleam/int
import gleam/list
import gleam/string
import util

pub type Machine {
  Machine(a: Button, b: Button, prize: Prize)
}

pub type Button {
  Button(x: Int, y: Int)
}

pub type Prize =
  #(Int, Int)

pub fn parse(input: String) -> List(Machine) {
  let machines = string.split(input, "\n\n")
  use machine <- list.map(machines)
  let assert [a_line, b_line, prize_line] = string.split(machine, "\n")
  Machine(parse_button(a_line), parse_button(b_line), parse_prize(prize_line))
}

fn parse_button(line: String) -> Button {
  let assert Ok(#(_, second)) = string.split_once(line, "X+")
  let assert Ok(#(x, y)) = string.split_once(second, ", Y+")
  Button(util.parse_int(x), util.parse_int(y))
}

fn parse_prize(line: String) -> Prize {
  let assert Ok(#(_, second)) = string.split_once(line, "X=")
  let assert Ok(#(x, y)) = string.split_once(second, ", Y=")
  #(util.parse_int(x), util.parse_int(y))
}

pub fn pt_1(input: List(Machine)) -> Int {
  list.map(input, calculate_min_tokens)
  |> list.fold(0, int.add)
}

fn calculate_min_tokens(machine: Machine) {
  let q = machine.a.x * machine.b.y - machine.b.x * machine.a.y
  let a = machine.prize.0 * machine.b.y + machine.prize.1 * -machine.b.x
  let b = machine.prize.0 * -machine.a.y + machine.prize.1 * machine.a.x
  case int.remainder(a, q), int.remainder(b, q) {
    Ok(0), Ok(0) -> 3 * { a / q } + { b / q }
    _, _ -> 0
  }
}

pub fn pt_2(input: List(Machine)) -> Int {
  list.map(input, fn(machine) {
    Machine(
      ..machine,
      prize: #(
        10_000_000_000_000 + machine.prize.0,
        10_000_000_000_000 + machine.prize.1,
      ),
    )
  })
  |> list.map(calculate_min_tokens)
  |> list.fold(0, int.add)
}
