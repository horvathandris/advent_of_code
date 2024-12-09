import gleam/int
import gleam/list
import gleam/option.{None, Some}
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
    case i % 2 == 0, util.parse_int(x) {
      True, 0 -> #(acc.0 + 1, acc.1)
      True, _ -> #(acc.0 + 1, [File(util.parse_int(x), id: acc.0), ..acc.1])
      False, 0 -> #(acc.0, acc.1)
      False, _ -> #(acc.0, [Empty(util.parse_int(x)), ..acc.1])
    }
  })
  |> fn(x) { x.1 }
  |> DiskMap
}

pub fn pt_1(input: DiskMap) -> Int {
  repartition_loop(input.blocks)
  |> list.reverse
  |> list.fold(#(0, 0), fn(acc, block) {
    case block {
      File(width, id) -> #(
        acc.0 + width,
        list.range(0, width - 1)
          |> list.fold(0, fn(file_sum, i) { file_sum + { acc.0 + i } * id })
          |> int.add(acc.1),
      )
      _ -> acc
    }
  })
  |> fn(x) { x.1 }
}

fn repartition_loop(input: List(Block)) -> List(Block) {
  let assert Ok(#(file, blocks)) =
    input
    |> list.pop(fn(block) {
      case block {
        File(_, _) -> True
        Empty(_) -> False
      }
    })

  let result =
    blocks
    |> list.reverse
    |> list.map_fold(Some(file), fn(acc, block) {
      case acc {
        Some(File(file_width, id)) ->
          case block {
            Empty(empty_width) -> {
              let new_partition_width = int.min(file_width, empty_width)
              case new_partition_width < empty_width {
                True -> #(None, [
                  File(new_partition_width, id),
                  Empty(empty_width - new_partition_width),
                ])
                False ->
                  case file_width - new_partition_width {
                    0 -> #(None, [File(new_partition_width, id)])
                    file_new_width -> #(Some(File(file_new_width, id)), [
                      File(new_partition_width, id),
                    ])
                  }
              }
            }
            File(_, _) -> #(acc, [block])
          }
        _ -> #(acc, [block])
      }
    })
    |> fn(x) {
      #(
        x.0,
        list.flatten(x.1)
          |> list.reverse,
      )
    }

  case result {
    #(Some(f), new_blocks) -> [f, ..new_blocks]
    #(_, new_blocks) -> repartition_loop(new_blocks)
  }
}

pub fn pt_2(input: DiskMap) -> Int {
  todo as "part 2 not implemented"
}
