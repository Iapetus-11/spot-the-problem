import services/users/routes/login as users_login
import web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  case req |> wisp.path_segments {
    ["login"] -> users_login.handler(req, ctx)
    _ -> wisp.not_found()
  }
}
