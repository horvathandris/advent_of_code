import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub type Round {
  Round(red: Int, green: Int, blue: Int)
}

pub type Game {
  Game(id: Int, rounds: List(Round))
}

pub fn parse(input: String) {
  let lines = string.split(input, "\n")
  use line <- list.filter_map(lines)

  let assert Ok(#(game, rounds)) = string.split_once(line, ":")

  case game {
    "Game " <> x ->
      int.parse(x)
      |> result.map(Game(id: _, rounds: parse_rounds(rounds)))
    _ -> Error(Nil)
  }
}

fn parse_rounds(input: String) -> List(Round) {
  let raw_rounds = string.split(input, ";")
  use raw_round <- list.map(raw_rounds)

  let balls_shown_per_round =
    string.split(raw_round, ",")
    |> list.map(string.trim_start)

  use accumulator, balls_shown <- list.fold(
    balls_shown_per_round,
    Round(0, 0, 0),
  )

  let assert Ok(#(number, colour)) = string.split_once(balls_shown, " ")
  let assert Ok(number) = int.parse(number)

  case colour {
    "red" -> Round(..accumulator, red: accumulator.red + number)
    "green" -> Round(..accumulator, green: number)
    "blue" -> Round(..accumulator, blue: number)
    _ -> accumulator
  }
}

pub fn pt_1(input: List(Game)) {
  let reds = 12
  let greens = 13
  let blues = 14

  use sum, game <- list.fold(input, 0)

  let max_balls_shown = max_balls_shown_in_game(game)

  let valid_game_id = case
    max_balls_shown.red <= reds,
    max_balls_shown.green <= greens,
    max_balls_shown.blue <= blues
  {
    True, True, True -> game.id
    _, _, _ -> 0
  }

  sum + valid_game_id
}

fn max_balls_shown_in_game(game: Game) {
  use accumulator, round <- list.fold(game.rounds, Round(0, 0, 0))

  let accumulator = case round.red > accumulator.red {
    True -> Round(..accumulator, red: round.red)
    False -> accumulator
  }

  let accumulator = case round.green > accumulator.green {
    True -> Round(..accumulator, green: round.green)
    False -> accumulator
  }

  case round.blue > accumulator.blue {
    True -> Round(..accumulator, blue: round.blue)
    False -> accumulator
  }
}

pub fn pt_2(input: List(Game)) {
  use sum, game <- list.fold(input, 0)

  let max_balls_shown = max_balls_shown_in_game(game)

  sum + { max_balls_shown.red * max_balls_shown.green * max_balls_shown.blue }
}
