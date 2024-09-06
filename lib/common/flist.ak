use aiken/builtin

// @TODO: Add tests
/// Gets an element from a list without destructuring more than once
/// If `at` is invalid (negative or out of range), it would fail.
/// This helper can be useful in a narrow scope where performance 
/// is a high priority
pub fn get(self: List<a>, at: Int) -> a {
  expect at >= 0
  expect [head, ..] = advance(self, at)
  head
}

pub fn oget(self: List<a>, at: Int) -> Option<a> {
  expect at >= 0
  when advance(self, at) is {
    [] -> None
    [head, ..] -> Some(head)
  }
}

fn advance(self: List<a>, idx: Int) -> List<a> {
  if idx >= 10 {
    advance(
      self
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list,
      idx - 10,
    )
  } else if idx >= 5 {
    advance(
      self
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list
        |> builtin.tail_list,
      idx - 5,
    )
  } else {
    advance_step_by_step(self, idx)
  }
}

fn advance_step_by_step(self: List<a>, idx: Int) -> List<a> {
  if idx == 0 {
    self
  } else {
    advance_step_by_step(builtin.tail_list(self), idx - 1)
  }
}

test fail_when_advance_empty_list() fail {
  builtin.tail_list([]) == []
}

test get_1() {
  get([0, 1, 2, 3], 0) == 0
}

test get_2() {
  get([0, 1, 2, 3], 1) == 1
}

test get_3() {
  get([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 10) == 10
}

test get_4() {
  get([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 11) == 11
}

test get_5() {
  get([0, 1, 2, 3, 4, 5, 6], 5) == 5
}

test get_6() {
  get([0, 1, 2, 3, 4, 5, 6], 6) == 6
}

// out of range
test get_7() fail {
  get([0, 1], 2) == 0
}

// negative index
test get_8() fail {
  get([0, 1], -1) == 0
}

// empty array
test get_9() fail {
  get([], 0) == 0
}

// out of range expect None
test oget_1() {
  oget([0, 1], 2) == None
}

test oget_2() {
  oget([0, 1], 1) == Some(1)
}

// empty array
test oget_3() fail {
  oget([], 0) == Some(0)
}
