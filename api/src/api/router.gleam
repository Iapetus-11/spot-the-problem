import api/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
    case wisp.path_segments {
        _ -> wisp.not_found()
    }
}