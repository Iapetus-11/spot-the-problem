import gleam/dict
import gleam/list
import gleam/string
import simplifile

pub type ProblemSet {
  ProblemSet(name: String, problems: List(String))
}

pub fn list_problems(category: String) -> List(String) {
  let assert Ok(file_names) =
    simplifile.read_directory("data/problems/" <> category <> "/")

  file_names
  |> list.filter(fn(file_name) {
    let assert Ok(is_file) = simplifile.is_file(file_name)
    is_file
  })
  // Chop off .json || .html
  |> list.map(string.drop_right(_, 5))
  |> list.unique
}

pub fn list_problem_sets() -> dict.Dict(String, ProblemSet) {
  let assert Ok(file_names) = simplifile.read_directory("data/problems/")

  file_names
  |> list.filter(fn(file_name) {
    let assert Ok(is_dir) = simplifile.is_directory(file_name)
    is_dir
  })
  |> list.map(fn(name) { #(name, ProblemSet(name, list_problems(name))) })
  |> dict.from_list
}
