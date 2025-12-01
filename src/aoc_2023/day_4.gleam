import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string

pub type Card {
  Card(id: Int, winning_numbers: List(Int), numbers: List(Int))
}

pub fn parse(input: String) -> List(Card) {
  let lines = string.split(input, "\n")
  use line <- list.map(lines)
  let assert Ok(#(card, numbers)) = string.split_once(line, ": ")
  let assert Ok(#(_, card_id)) = string.split_once(card, "Card ")
  let assert Ok(card_id) = string.trim(card_id) |> int.parse
  let assert Ok(#(winning_numbers, numbers)) = string.split_once(numbers, "|")
  let winning_numbers =
    string.split(winning_numbers, " ")
    |> list.map(string.trim)
    |> list.filter_map(int.parse)

  let numbers =
    string.split(numbers, " ")
    |> list.map(string.trim)
    |> list.filter_map(int.parse)

  Card(id: card_id, winning_numbers:, numbers:)
}

pub fn pt_1(input: List(Card)) {
  use sum, card <- list.fold(input, 0)
  sum + calculate_card(card)
}

fn calculate_matches(card: Card) -> Int {
  let winning_set = set.from_list(card.winning_numbers)
  let your_set = set.from_list(card.numbers)

  set.intersection(winning_set, your_set)
  |> set.size
}

fn calculate_card(card: Card) -> Int {
  let number_of_winners = calculate_matches(card)

  int.power(2, int.to_float(number_of_winners - 1))
  |> result.unwrap(0.0)
  |> float.truncate
}

pub fn pt_2(input: List(Card)) {
  let matches =
    list.map(input, fn(card) { #(card.id, calculate_matches(card)) })

  let initial =
    list.map(input, fn(card) { #(card.id, 1) })
    |> dict.from_list

  list.fold(matches, initial, fn(acc, card_matches) {
    let card_id = card_matches.0
    let matches = card_matches.1

    let assert Ok(to_add) = dict.get(acc, card_id)

    case card_id + 1 > card_id + matches {
      True -> acc
      False ->
        list.range(card_id + 1, card_id + matches)
        |> list.fold(acc, fn(inner_acc, inner_card_id) {
          dict.upsert(inner_acc, inner_card_id, fn(value) {
            case value {
              option.None -> 1
              option.Some(old) -> old + to_add
            }
          })
        })
    }
  })
  |> dict.values
  |> list.fold(0, fn(sum, value) { sum + value })
}
