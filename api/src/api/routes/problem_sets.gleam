import api/web.{type Context}
import gleam/dict
import gleam/json
import wisp.{type Request, type Response}

pub fn get_list(req: Request, ctx: Context) -> Response {
  ctx.problem_sets
  |> dict.to_list
  |> json.array(fn(key_and_list) { json.string(key_and_list.0) })

  wisp.json_response(json.to_string_builder(json.string("Test")), 200)
}
