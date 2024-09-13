import api/web.{type Context}
import common/authentication
import common/dynamic_utils.{encode_errors_to_json_string}
import gleam/bit_array
import gleam/dynamic
import gleam/http
import gleam/json
import gleam/option
import gleam/pgo
import services/users/sql as users_sql
import wisp.{type Request, type Response}

type LoginCredentials {
  LoginCredentials(username: String, password: String)
}

fn require_login_credentials(req: Request, continue) {
  use json_body <- wisp.require_json(req)

  case
    dynamic.decode2(
      LoginCredentials,
      dynamic.field("username", of: dynamic.string),
      dynamic.field("password", of: dynamic.string),
    )(json_body)
  {
    Ok(login_creds) -> continue(login_creds)
    Error(errors) ->
      wisp.json_response(encode_errors_to_json_string(errors), 400)
  }
}

pub fn post_login(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Post)
  use login_creds <- require_login_credentials(req)

  // This is extremely insecure, I don't care. I should be hashing passwords using salt + pepper, returning a JWT, and have
  // some sort of rate limiting, but I'm too lazy :)
  case
    users_sql.find_user_from_username_and_password(
      ctx.db,
      login_creds.username,
      login_creds.password,
    )
  {
    Ok(pgo.Returned(
      1,
      [
        users_sql.FindUserFromUsernameAndPasswordRow(
          _,
          _,
          option.Some(login_hash),
        ),
      ],
    )) -> {
      wisp.json_response(
        json.to_string_builder(
          json.object([
            #(
              "login_hash",
              json.string(bit_array.base64_url_encode(login_hash, False)),
            ),
          ]),
        ),
        200,
      )
    }
    Ok(pgo.Returned(0, [])) -> wisp.response(403)
    _ -> wisp.internal_server_error()
  }
}

pub fn get_self(req: Request, ctx: Context) -> Response {
  use user <- authentication.require_authorized_user(req, ctx.db)

  wisp.json_response(
    json.to_string_builder(
      json.object([
        #("id", json.int(user.id)),
        #("username", json.string(user.username)),
      ]),
    ),
    200,
  )
}
