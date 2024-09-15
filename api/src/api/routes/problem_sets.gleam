import api/web.{type Context}
import gleam/dict
import gleam/json
import services/problem_sets
import wisp.{type Request, type Response}

pub fn get_list(_req: Request, ctx: Context) -> Response {
  ctx.problem_sets
  |> dict.to_list
  |> json.array(fn(key_and_list) { json.string(key_and_list.0) })
  |> json.to_string_builder
  |> wisp.json_response(200)
}

pub fn get_problems_list(
  req: Request,
  ctx: Context,
  problem_set_name: String,
) -> Response {
  case dict.get(ctx.problem_sets, problem_set_name) {
    Ok(problem_set) ->
      wisp.json_response(
        json.to_string_builder(
          json.array(problem_set.problems, fn(p) {
            // Yes this makes a file read for every problem, this is an intentional tradeoff
            // to save on memory because this API won't be used often, still, it could be cached
            let p = problem_sets.get_problem_info(problem_set.name, p)
            json.object([
              #("category", json.string(p.category)),
              #("description", json.string(p.description)),
              #("answer", json.string(p.answer)),
              #("difficulty", json.int(p.difficulty)),
            ])
          }),
        ),
        200,
      )
    _ -> wisp.not_found()
  }
}
