import common.{type Location}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util

pub type Robot {
  Robot(position: Location, velocity: #(Int, Int))
}

pub type Grid {
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
    False -> {
      let grid = move_robots(grid)
      // print_grid(grid)
      move_robots_n_times(grid, n - 1)
    }
  }
}

fn move_robots(grid: Grid) -> Grid {
  Grid(
    ..grid,
    robots: list.map(grid.robots, fn(robot) { move_robot(robot, grid.size) }),
  )
}

fn move_robot(robot: Robot, bounds: #(Int, Int)) -> Robot {
  Robot(
    ..robot,
    position: #(
      next_coordinate(robot.position.0, robot.velocity.0, bounds.0),
      next_coordinate(robot.position.1, robot.velocity.1, bounds.1),
    ),
  )
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
  get_quadrants(grid.size)
  |> list.fold(1, fn(acc, quadrant) {
    list.count(grid.robots, fn(robot) {
      robot.position.0 >= quadrant.0.0
      && robot.position.0 <= quadrant.0.1
      && robot.position.1 >= quadrant.1.0
      && robot.position.1 <= quadrant.1.1
    })
    * acc
  })
}

pub fn pt_2(input: List(Robot)) -> Int {
  todo as "part 2 not implemented"
}

fn print_grid(grid: Grid) -> Nil {
  io.println("")
  list.range(0, grid.size.1 - 1)
  |> list.map(fn(i) {
    list.range(0, grid.size.0 - 1)
    |> list.map(fn(j) {
      case list.count(grid.robots, fn(robot) { robot.position == #(j, i) }) {
        0 -> "."
        n -> int.to_string(n)
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
}
