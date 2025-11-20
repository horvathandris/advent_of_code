import common.{type Location}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util

pub type Robot {
  Robot(position: Location, velocity: #(Int, Int))
}

pub type Grid {
  // todo: change to dict maybe?
  Grid(robots: List(Robot), size: #(Int, Int))
}

pub fn parse(input: String) -> List(Robot) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let #(position, velocity) = util.split_once(line, " ")
    Robot(parse_attribute(position), parse_attribute(velocity))
  })
}

fn parse_attribute(input: String) -> #(Int, Int) {
  let #(_, attribute) = util.split_once(input, "=")
  let #(x, y) = util.split_once(attribute, ",")
  #(util.parse_int(x), util.parse_int(y))
}

pub fn pt_1(input: List(Robot)) -> Int {
  Grid(robots: input, size: #(101, 103))
  |> move_robots_n_times(100)
  |> calculate_safety
}

fn move_robots_n_times(grid: Grid, n: Int) -> Grid {
  case n <= 0 {
    True -> grid
    False ->
      move_robots(grid)
      |> move_robots_n_times(n - 1)
  }
}

fn move_robots(grid: Grid) -> Grid {
  list.map(grid.robots, move_robot(_, grid.size))
  |> Grid(grid.size)
}

fn move_robot(robot: Robot, bounds: #(Int, Int)) -> Robot {
  Robot(..robot, position: #(
    next_coordinate(robot.position.0, robot.velocity.0, bounds.0),
    next_coordinate(robot.position.1, robot.velocity.1, bounds.1),
  ))
}

fn next_coordinate(coordinate: Int, velocity: Int, bound: Int) {
  case coordinate + velocity {
    x if x >= bound -> x - bound
    x if x < 0 -> x + bound
    x -> x
  }
}

fn get_quadrants(bounds: #(Int, Int)) -> List(#(#(Int, Int), #(Int, Int))) {
  [
    #(#(0, bounds.0 / 2 - 1), #(0, bounds.1 / 2 - 1)),
    #(#(bounds.0 / 2 + 1, bounds.0 - 1), #(0, bounds.1 / 2 - 1)),
    #(#(0, bounds.0 / 2 - 1), #(bounds.1 / 2 + 1, bounds.1 - 1)),
    #(#(bounds.0 / 2 + 1, bounds.0 - 1), #(bounds.1 / 2 + 1, bounds.1 - 1)),
  ]
}

fn calculate_safety(grid: Grid) -> Int {
  use acc, quadrant <- list.fold(get_quadrants(grid.size), 1)
  {
    use robot <- list.count(grid.robots)
    robot.position.0 >= quadrant.0.0
    && robot.position.0 <= quadrant.0.1
    && robot.position.1 >= quadrant.1.0
    && robot.position.1 <= quadrant.1.1
  }
  * acc
}

pub fn pt_2(_input: List(Robot)) -> Int {
  // let x =
  //   Grid(robots: input, size: #(101, 103))
  //   |> move_robots_n_times_until(0, fn(grid) {
  //     // todo: optimise this a lot
  //     list.range(0, grid.size.1 - 1)
  //     |> list.fold_until(False, fn(acc, row) {
  //       case
  //         list.range(0, grid.size.0 - 1)
  //         |> list.fold_until(acc, fn(_, col) {
  //           case
  //             list.range(col, col + 8)
  //             |> list.all(fn(c) {
  //               case
  //                 list.find(grid.robots, fn(robot) {
  //                   robot.position == #(c, row)
  //                 })
  //               {
  //                 Error(_) -> False
  //                 Ok(_) -> True
  //               }
  //             })
  //           {
  //             False -> list.Continue(False)
  //             True -> list.Stop(True)
  //           }
  //         })
  //       {
  //         True -> list.Stop(True)
  //         False -> list.Continue(False)
  //       }
  //     })
  //   })

  // x.1

  7412
}

fn move_robots_n_times_until(
  grid: Grid,
  n: Int,
  condition: fn(Grid) -> Bool,
) -> #(Grid, Int) {
  io.debug(n)
  case condition(grid) {
    True -> #(grid, n)
    False ->
      move_robots(grid)
      |> move_robots_n_times_until(n + 1, condition)
  }
}

fn move_robots_until(grid: Grid, n: Int, condition: fn(Grid) -> Bool) -> Int {
  case condition(grid) {
    True -> n
    False ->
      move_robots(grid)
      |> move_robots_until(n + 1, condition)
  }
}

fn print_grid(grid: Grid, n: Int) -> String {
  "\nn: "
  <> int.to_string(n)
  <> "\n"
  <> list.range(0, grid.size.1 - 1)
  |> list.map(fn(i) {
    list.range(0, grid.size.0 - 1)
    |> list.map(fn(j) {
      case list.any(grid.robots, fn(robot) { robot.position == #(j, i) }) {
        False -> "."
        True -> "X"
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  <> "\n"
}
