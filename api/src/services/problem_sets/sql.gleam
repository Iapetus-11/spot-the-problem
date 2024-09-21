import decode
import gleam/pgo

/// A row you get from running the `find_answer_for_user_and_problem` query
/// defined in `./src/services/problem_sets/sql/find_answer_for_user_and_problem.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindAnswerForUserAndProblemRow {
  FindAnswerForUserAndProblemRow(
    id: Int,
    user_id: Int,
    problem_set: String,
    problem_id: String,
    answer_line: Int,
    answer: String,
  )
}

/// Runs the `find_answer_for_user_and_problem` query
/// defined in `./src/services/problem_sets/sql/find_answer_for_user_and_problem.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_answer_for_user_and_problem(db, arg_1, arg_2, arg_3) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      use problem_set <- decode.parameter
      use problem_id <- decode.parameter
      use answer_line <- decode.parameter
      use answer <- decode.parameter
      FindAnswerForUserAndProblemRow(
        id: id,
        user_id: user_id,
        problem_set: problem_set,
        problem_id: problem_id,
        answer_line: answer_line,
        answer: answer,
      )
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.int)
    |> decode.field(2, decode.string)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.int)
    |> decode.field(5, decode.string)

  "SELECT * FROM answers WHERE user_id = $1 AND problem_set = $2 AND problem_id = $3"
  |> pgo.execute(
    db,
    [pgo.int(arg_1), pgo.text(arg_2), pgo.text(arg_3)],
    decode.from(decoder, _),
  )
}
