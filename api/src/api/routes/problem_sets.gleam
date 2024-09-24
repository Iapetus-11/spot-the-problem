import api/authentication
import api/web.{type Context}
import common/result_utils.{try_unwrap}
import gleam/dict
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/order
import gleam/pgo
import gleam/string
import services/problem_sets/problem_sets
import services/problem_sets/sql as problem_sets_sql
import wisp.{type Request, type Response}

pub fn get_list(_req: Request, ctx: Context) -> Response {
  ctx.problem_sets
  |> dict.to_list
  |> json.array(fn(key_and_list) { json.string(key_and_list.0) })
  |> json.to_string_builder
  |> wisp.json_response(200)
}

pub fn get_problems_list(
  _req: Request,
  ctx: Context,
  problem_set_name: String,
) -> Response {
  use problem_set <- try_unwrap(case
    dict.get(ctx.problem_sets, problem_set_name)
  {
    Ok(problem_set) -> Ok(problem_set)
    _ -> Error(wisp.not_found())
  })

  problem_set.problems
  |> dict.to_list()
  |> list.map(fn(p) {
    // Yes this makes a file read for every problem, this is an intentional tradeoff
    // to save on memory because this API won't be used often, still, it could be cached
    problem_sets.get_problem_info(problem_set.name, p.1)
  })
  |> list.sort(fn(p_a, p_b) {
    case int.compare(p_a.difficulty, p_b.difficulty) {
      order.Eq -> string.compare(p_a.name, p_b.name)
      comparison -> comparison
    }
  })
  |> json.array(fn(p) {
    json.object([
      #("id", json.string(p.id)),
      #("name", json.string(p.name)),
      #("category", json.string(p.category)),
      #("description", json.string(p.description)),
      #("answer", json.string(p.answer)),
      #("difficulty", json.int(p.difficulty)),
    ])
  })
  |> json.to_string_builder()
  |> wisp.json_response(200)
}

pub fn get_problem(
  req: Request,
  ctx: Context,
  problem_set_name: String,
  problem_id: String,
) -> Response {
  use authorized_user <- authentication.get_authorized_user_if_present(
    req,
    ctx.db,
  )

  use problem_set <- try_unwrap(case
    dict.get(ctx.problem_sets, problem_set_name)
  {
    Ok(problem_sets) -> Ok(problem_sets)
    _ -> Error(wisp.not_found())
  })

  use problem_name <- try_unwrap(case
    dict.get(problem_set.problems, problem_id)
  {
    Ok(problem_name) -> Ok(problem_name)
    _ -> Error(wisp.not_found())
  })

  let #(problem_info, problem_content) =
    problem_sets.get_problem_info_with_content(problem_set_name, problem_name)

  let user_answer = case authorized_user {
    Ok(user) ->
      case
        problem_sets_sql.find_answer_for_user_and_problem(
          ctx.db,
          user.id,
          problem_set_name,
          problem_id,
        )
      {
        Ok(pgo.Returned(1, [answer])) ->
          option.Some([
            #("answer", json.string(answer.answer)),
            #("line", json.int(answer.answer_line)),
          ])
        _ -> option.None
      }
    _ -> option.None
  }

  json.object([
    #("id", json.string(problem_info.id)),
    #("name", json.string(problem_info.name)),
    #("category", json.string(problem_info.category)),
    #("description", json.string(problem_info.description)),
    #("answer", json.string(problem_info.answer)),
    #("difficulty", json.int(problem_info.difficulty)),
    #("content", json.string(problem_content)),
    #("user_answer", json.nullable(user_answer, json.object)),
  ])
  |> json.to_string_builder()
  |> wisp.json_response(200)
}
