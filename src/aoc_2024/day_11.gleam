import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import parallel_map
import util

pub fn parse(input: String) -> List(Int) {
  string.split(input, " ")
  |> list.map(util.parse_int)
}

pub fn pt_1(input: List(Int)) -> Int {
  // let fun = fn(stone) { blink_n_times([stone], 25) }
  // parallel_map.list_pmap(input, fun, parallel_map.WorkerAmount(8), 100_000)
  // |> list.map(result.lazy_unwrap(_, fn() { [] }))
  // |> list.map(list.length)
  // |> list.fold(0, int.add)
  blink_n_times(input, 25)
}

fn blink_n_times(stones: List(Int), n: Int) -> Int {
  case n {
    0 -> list.length(stones)
    _ ->
      list.fold(stones, 0, fn(acc, stone) {
        {
          case stone {
            0 -> [1]
            _ -> {
              let digits = number_of_digits(stone, 0)
              case digits % 2 == 0 {
                True -> split_stone(stone, digits)
                _ -> [stone * 2024]
              }
            }
          }
          |> blink_n_times(n - 1)
        }
        + acc
      })
  }
}

fn number_of_digits(stone: Int, digits: Int) -> Int {
  case stone > 0 {
    True -> number_of_digits(stone / 10, digits + 1)
    _ -> digits
  }
}

fn split_stone(stone: Int, digits: Int) -> List(Int) {
  let half_digits = digits / 2
  let divisor = util.power(10, half_digits)
  [stone / divisor, stone % divisor]
}

pub fn pt_2(input: List(Int)) -> Int {
  let fun = fn(stone) { blink_n_times([stone], 45) }
  parallel_map.list_pmap(input, fun, parallel_map.WorkerAmount(8), 100_000)
  |> list.map(result.lazy_unwrap(_, fn() { 0 }))
  |> list.fold(0, int.add)
  // blink_n_times(input, 30)
}
