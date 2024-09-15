import api/routes/problem_sets as problem_set_routes
import api/routes/users as user_routes
import api/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  case req |> wisp.path_segments {
    ["login"] -> user_routes.post_login(req, ctx)
    ["users", "self"] -> user_routes.get_self(req, ctx)
    ["problem_sets"] -> problem_set_routes.get_list(req, ctx)
    ["problem_sets", problem_set_name] ->
      problem_set_routes.get_problems_list(req, ctx, problem_set_name)
    _ -> wisp.not_found()
  }
}
