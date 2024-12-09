import gleam/list
import gleam/string
import util

pub type DiskMap {
  DiskMap(blocks: List(Block))
}

pub type Block {
  Empty(width: Int)
  File(width: Int, id: Int)
}

pub fn parse(input: String) -> DiskMap {
  string.split(input, "")
  |> list.index_fold(#(0, []), fn(acc, x, i) {
    case i % 2 == 0 {
      True -> #(acc.0 + 1, [File(util.parse_int(x), id: acc.0), ..acc.1])
      False -> #(acc.0, [Empty(util.parse_int(x)), ..acc.1])
    }
  })
  |> fn(x) { x.1 }
  |> DiskMap
}

pub fn pt_1(input: DiskMap) -> Int {
  todo as "part 1 not implemented"
}

pub fn pt_2(input: DiskMap) -> Int {
  todo as "part 2 not implemented"
}
