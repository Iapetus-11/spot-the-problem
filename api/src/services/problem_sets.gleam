import gleam/dict
import gleam/dynamic
import gleam/json
import gleam/list
import gleam/string
import simplifile

pub type ProblemSet {
  ProblemSet(name: String, problems: dict.Dict(String, String))
}

pub type ProblemInfo {
  ProblemInfo(
    id: String,
    name: String,
    category: String,
    description: String,
    answer: String,
    difficulty: Int,
    file_ext: String,
  )
}

pub type ProblemInfoWithContent =
  #(ProblemInfo, String)

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
      dynamic.decode7(
        ProblemInfo,
        dynamic.field("id", dynamic.string),
        dynamic.field("name", dynamic.string),
        dynamic.field("category", dynamic.string),
        dynamic.field("description", dynamic.string),
        dynamic.field("answer", dynamic.string),
        dynamic.field("difficulty", dynamic.int),
        dynamic.field("file_ext", dynamic.string),
      )(data)
    })

  problem_info
}

pub fn get_problem_info_with_content(
  problem_set: String,
  problem_name: String,
) -> ProblemInfoWithContent {
  let problem_info = get_problem_info(problem_set, problem_name)

  let assert Ok(problem_content) =
    simplifile.read(
      "src/data/problems/"
      <> problem_set
      <> "/"
      <> problem_name
      <> "."
      <> problem_info.file_ext,
    )

  #(problem_info, problem_content)
}

pub fn get_problems_mapping(problem_set: String) -> dict.Dict(String, String) {
  let assert Ok(file_names) =
    simplifile.read_directory("src/data/problems/" <> problem_set <> "/")

  file_names
  // Chop off .json || .html
  |> list.map(string.drop_right(_, 5))
  |> list.unique()
  |> list.map(fn(problem_name) {
    let problem_info = get_problem_info(problem_set, problem_name)
    #(problem_info.id, problem_name)
  })
  |> dict.from_list
}

pub fn list_problem_sets() -> dict.Dict(String, ProblemSet) {
  let assert Ok(file_names) = simplifile.read_directory("src/data/problems/")

  file_names
  |> list.map(fn(name) { #(name, ProblemSet(name, get_problems_mapping(name))) })
  |> dict.from_list
}
