use aiken/builtin
use aiken/collection/list

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

pub fn get_with_tail(self: List<a>, at: Int) -> (Option<a>, List<a>) {
  expect at >= 0
  when advance(self, at) is {
    [] -> (None, [])
    [head, ..rest] -> (Some(head), rest)
  }
}

test get_with_tail_1() {
  get_with_tail([1, 2, 3, 4], 0) == (Some(1), [2, 3, 4])
}

test get_with_tail_2() {
  get_with_tail([1, 2, 3, 4], 1) == (Some(2), [3, 4])
}

test get_with_tail_3() {
  get_with_tail([1, 2, 3, 4], 3) == (Some(4), [])
}

const l =
  [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
    22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
    22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
  ]

test get_with_tail_4() {
  get_with_tail(l, 117) == (Some(59), [])
}

test get_with_tail_5() {
  get(l, 117) == 59
}

test get_with_tail_6() {
  oget(l, 117) == Some(59)
}

test get_with_tail_7() {
  list.at(l, 117) == Some(59)
}

pub fn advance(self: List<a>, idx: Int) -> List<a> {
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
