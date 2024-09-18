import api/web.{type Context}
import gleam/dict
import gleam/int
import gleam/json
import gleam/list
import gleam/order
import gleam/string
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
  _req: Request,
  ctx: Context,
  problem_set_name: String,
) -> Response {
  case dict.get(ctx.problem_sets, problem_set_name) {
    Ok(problem_set) ->
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
    _ -> wisp.not_found()
  }
}

pub fn get_problem(
  _req: Request,
  ctx: Context,
  problem_set_name: String,
  problem_name: String,
) -> Response {
  case dict.get(ctx.problem_sets, problem_set_name) {
    Ok(problem_set) -> {
      case dict.get(problem_set.problems, problem_name) {
        Ok(problem_name) -> {
          problem_sets.get_problem_info_with_content(
            problem_set_name,
            problem_name,
          )
          |> fn(p: problem_sets.ProblemInfoWithContent) {
            let #(p, content) = p
            json.object([
              #("id", json.string(p.id)),
              #("name", json.string(p.name)),
              #("category", json.string(p.category)),
              #("description", json.string(p.description)),
              #("answer", json.string(p.answer)),
              #("difficulty", json.int(p.difficulty)),
              #("content", json.string(content)),
            ])
          }
          |> json.to_string_builder()
          |> wisp.json_response(200)
        }
        _ -> wisp.not_found()
      }
    }
    _ -> wisp.not_found()
  }
}
