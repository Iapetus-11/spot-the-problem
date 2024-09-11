import gleam/http
import services/users/routes as user_routes
import web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  case req |> wisp.path_segments {
    ["login"] -> {
      use <- wisp.require_method(req, http.Post)
      user_routes.post_login(req, ctx)
    }
    _ -> wisp.not_found()
  }
}
