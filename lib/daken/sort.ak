use aiken/collection/list
use cardano/transaction.{Input, OutputReference}

pub fn inputs_sort_asc(inputs: List<Input>) -> List<Input> {
  inputs
    |> list.sort(
        fn(
          Input {
            output_reference: OutputReference { output_index: a_idx, .. },
            ..
          },
          Input {
            output_reference: OutputReference { output_index: b_idx, .. },
            ..
          },
        ) -> Ordering {
          if a_idx < b_idx {
            Less
          } else if a_idx == b_idx {
            Equal
          } else {
            Greater
          }
        },
      )
}

pub fn inputs_quicksort_asc(inputs: List<Input>) -> List<Input> {
  when inputs is {
    [] -> []
    [p, ..tail] -> {
      let Input {
        output_reference: OutputReference { output_index: p_idx, .. },
        ..
      } = p
      tail
        |> list.filter(
            fn(
              Input {
                output_reference: OutputReference { output_index: a_idx, .. },
                ..
              },
            ) {
              a_idx <= p_idx
            },
          )
        |> inputs_quicksort_asc
        |> list.concat(
            [
              p,
              ..tail
                |> list.filter(
                    fn(
                      Input {
                        output_reference: OutputReference {
                          output_index: a_idx,
                          ..
                        },
                        ..
                      },
                    ) {
                      a_idx > p_idx
                    },
                  )
                |> inputs_quicksort_asc
            ],
          )
    }
  }
}

pub fn out_refs_sort_asc(
  out_refs: List<OutputReference>,
) -> List<OutputReference> {
  out_refs
    |> list.sort(
        fn(
          OutputReference { output_index: a_idx, .. },
          OutputReference { output_index: b_idx, .. },
        ) -> Ordering {
          if a_idx < b_idx {
            Less
          } else if a_idx == b_idx {
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
    [] -> []
    [p, ..tail] -> {
      let OutputReference { output_index: p_idx, .. } = p
      tail
        |> list.filter(
            fn(OutputReference { output_index: a_idx, .. }) { a_idx <= p_idx },
          )
        |> out_refs_quicksort_asc
        |> list.concat(
            [
              p,
              ..tail
                |> list.filter(
                    fn(OutputReference { output_index: a_idx, .. }) {
                      a_idx > p_idx
                    },
                  )
                |> out_refs_quicksort_asc
            ],
          )
    }
  }
}
