import common/http.{require_header_value}
import gleam/bit_array
import gleam/json
import gleam/option
import gleam/pgo
import services/users/sql as users_sql
import wisp.{type Request, type Response}

pub type AuthorizedUser {
  AuthorizedUser(id: Int, username: String)
}

fn require_base64_authorization_header(
  auth_header: String,
  continue: fn(BitArray) -> _,
) -> Response {
  case bit_array.base64_url_decode(auth_header) {
    Ok(decoded_auth_header) -> continue(decoded_auth_header)
    _ ->
      wisp.json_response(
        {
          json.object([
            #(
              "headers",
              json.object([
                #(
                  "Authorization",
                  json.array(
                    ["Expected valid base64 but found invalid base64."],
                    json.string(_),
                  ),
                ),
              ]),
            ),
          ])
          |> json.to_string_builder
        },
        403,
      )
  }
}

pub fn require_authorized_user(
  req: Request,
  db: pgo.Connection,
  continue: fn(AuthorizedUser) -> _,
) -> Response {
  use auth_header <- require_header_value(req, "Authorization", 403)

  use login_hash <- require_base64_authorization_header(auth_header)

  case users_sql.find_user_from_login_hash(db, login_hash) {
    Ok(pgo.Returned(
      1,
      [users_sql.FindUserFromLoginHashRow(id, option.Some(username), _)],
    )) -> continue(AuthorizedUser(id, username))
    // TODO: Add an error messsage?
    Ok(pgo.Returned(0, [])) -> wisp.response(403)
    // TODO: Add an error message
    _ -> wisp.internal_server_error()
  }
}
