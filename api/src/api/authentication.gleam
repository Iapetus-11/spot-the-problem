import common/http_utils.{require_header_value}
import common/json_utils
import common/result_utils.{try_unwrap}
import gleam/bit_array
import gleam/json
import gleam/list
import gleam/pgo
import gleam/string
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
    Error(_) ->
      json_utils.make_nested_json_object([
        #(
          ["headers", "Authorization"],
          json.string("Expected valid base64 but found invalid base64."),
        ),
      ])
      |> json.to_string_builder()
      |> wisp.json_response(403)
  }
}

pub fn get_authorized_user_if_present(
  req: Request,
  db: pgo.Connection,
  continue: fn(Result(AuthorizedUser, Nil)) -> _,
) -> Response {
  use auth_header <- try_unwrap(case
    list.find_map(req.headers, fn(key_and_value) {
      let #(key, value) = key_and_value
      case string.capitalise(key) {
        key if key == "Authorization" -> Ok(value)
        _ -> Error(Nil)
      }
    })
  {
    Ok(auth_header) -> Ok(auth_header)
    Error(_) -> Error(continue(Error(Nil)))
  })

  use login_hash <- require_base64_authorization_header(auth_header)

  case users_sql.find_user_from_login_hash(db, login_hash) {
    Ok(pgo.Returned(1, [users_sql.FindUserFromLoginHashRow(id, username, _)])) ->
      continue(Ok(AuthorizedUser(id, username)))
    Ok(pgo.Returned(0, [])) -> continue(Error(Nil))
    _ -> wisp.internal_server_error()
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
    Ok(pgo.Returned(1, [users_sql.FindUserFromLoginHashRow(id, username, _)])) ->
      continue(AuthorizedUser(id, username))
    Ok(pgo.Returned(0, [])) -> wisp.response(403)
    _ -> wisp.internal_server_error()
  }
}
