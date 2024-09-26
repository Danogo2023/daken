use aiken/collection/list
use cardano/transaction.{Input, OutputReference}

pub fn inputs_sort_asc(inputs: List<Input>) -> List<Input> {
  list.sort(
    inputs,
    fn(a: Input, b: Input) -> Ordering {
      if a.output_reference.output_index < b.output_reference.output_index {
        Less
      } else if a.output_reference.output_index == b.output_reference.output_index {
        Equal
      } else {
        Greater
      }
    },
  )
}

pub fn inputs_quicksort_asc(inputs: List<Input>) -> List<Input> {
  when inputs is {
    [] ->
      []
    [p, ..tail] -> {
      let before =
        tail
          |> list.filter(
              fn(x) {
                x.output_reference.output_index <= p.output_reference.output_index
              },
            )
          |> inputs_quicksort_asc
      let after =
        tail
          |> list.filter(
              fn(x) {
                x.output_reference.output_index > p.output_reference.output_index
              },
            )
          |> inputs_quicksort_asc
      list.concat(before, [p, ..after])
    }
  }
}

pub fn out_refs_sort_asc(
  out_refs: List<OutputReference>,
) -> List<OutputReference> {
  list.sort(
    out_refs,
    fn(a: OutputReference, b: OutputReference) -> Ordering {
      if a.output_index < b.output_index {
        Less
      } else if a.output_index == b.output_index {
        Equal
      } else {
        Greater
      }
    },
  )
}

pub fn out_refs_quicksort_asc(
  out_refs: List<OutputReference>,
) -> List<OutputReference> {
  when out_refs is {
    [] ->
      []
    [p, ..tail] -> {
      let before =
        tail
          |> list.filter(fn(x) { x.output_index <= p.output_index })
          |> out_refs_quicksort_asc
      let after =
        tail
          |> list.filter(fn(x) { x.output_index > p.output_index })
          |> out_refs_quicksort_asc
      list.concat(before, [p, ..after])
    }
  }
}
