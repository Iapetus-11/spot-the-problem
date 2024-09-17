import gleam/dict
import gleam/dynamic
import gleam/json
import gleam/list
import gleam/string
import simplifile

pub type ProblemSet {
  ProblemSet(name: String, problems: List(String))
}

pub type ProblemInfo {
  ProblemInfo(
    name: String,
    category: String,
    description: String,
    answer: String,
    difficulty: Int,
  )
}

pub fn list_problems(category: String) -> List(String) {
  let assert Ok(file_names) =
    simplifile.read_directory("src/data/problems/" <> category <> "/")

  file_names
  // Chop off .json || .html
  |> list.map(string.drop_right(_, 5))
  |> list.unique
}

pub fn list_problem_sets() -> dict.Dict(String, ProblemSet) {
  let assert Ok(file_names) = simplifile.read_directory("src/data/problems/")

  file_names
  |> list.map(fn(name) { #(name, ProblemSet(name, list_problems(name))) })
  |> dict.from_list
}

pub fn get_problem_info(
  problem_set: String,
  problem_name: String,
) -> ProblemInfo {
  let assert Ok(file) =
    simplifile.read(
      "src/data/problems/" <> problem_set <> "/" <> problem_name <> ".json",
    )

  let assert Ok(problem_info) =
    json.decode(file, fn(data) {
      dynamic.decode5(
        ProblemInfo,
        dynamic.field("name", dynamic.string),
        dynamic.field("category", dynamic.string),
        dynamic.field("description", dynamic.string),
        dynamic.field("answer", dynamic.string),
        dynamic.field("difficulty", dynamic.int),
      )(data)
    })

  problem_info
}
