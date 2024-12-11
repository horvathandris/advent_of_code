import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import util

pub fn parse(input: String) -> List(Int) {
  string.split(input, " ")
  |> list.map(util.parse_int)
}

pub fn pt_1(input: List(Int)) -> Int {
  count_stones_after_n_blinks(input, 25)
}

pub fn pt_2(input: List(Int)) -> Int {
  count_stones_after_n_blinks(input, 75)
}

fn count_stones_after_n_blinks(input: List(Int), n: Int) {
  list.map_fold(input, dict.new(), fn(mem, stone) { score(stone, n, mem) }).1
  |> list.fold(0, int.add)
}

fn score(
  stone: Int,
  n: Int,
  mem: Dict(#(Int, Int), Int),
) -> #(Dict(#(Int, Int), Int), Int) {
  case n {
    0 -> #(mem, 1)
    _ ->
      case dict.get(mem, #(stone, n)) {
        Ok(s) -> #(mem, s)
        _ ->
          case stone {
            0 -> score(1, n - 1, mem)
            _ -> {
              let digits = number_of_digits(stone, 0)
              case digits % 2 == 0 {
                True -> {
                  let #(first, second) = split_stone(stone, digits)
                  let #(mem, first_score) = score(first, n - 1, mem)
                  let #(mem, second_score) = score(second, n - 1, mem)
                  #(mem, first_score + second_score)
                }
                _ -> score(stone * 2024, n - 1, mem)
              }
            }
          }
          |> fn(x) { #(dict.insert(x.0, #(stone, n), x.1), x.1) }
      }
  }
}

fn number_of_digits(stone: Int, digits: Int) -> Int {
  case stone > 0 {
    True -> number_of_digits(stone / 10, digits + 1)
    _ -> digits
  }
}

fn split_stone(stone: Int, digits: Int) -> #(Int, Int) {
  let half_digits = digits / 2
  let divisor = util.power(10, half_digits)
  #(stone / divisor, stone % divisor)
}
