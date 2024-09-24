import decode
import gleam/pgo

/// A row you get from running the `find_user_from_username_and_password` query
/// defined in `./src/services/users/sql/find_user_from_username_and_password.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserFromUsernameAndPasswordRow {
  FindUserFromUsernameAndPasswordRow(
    id: Int,
    username: String,
    login_hash: BitArray,
  )
}

/// Runs the `find_user_from_username_and_password` query
/// defined in `./src/services/users/sql/find_user_from_username_and_password.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_user_from_username_and_password(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use username <- decode.parameter
      use login_hash <- decode.parameter
      FindUserFromUsernameAndPasswordRow(
        id: id,
        username: username,
        login_hash: login_hash,
      )
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.bit_array)

  "SELECT * FROM users WHERE login_hash = SHA512(($1 || '#' || $2)::BYTEA);"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _))
}

/// A row you get from running the `find_user_from_login_hash` query
/// defined in `./src/services/users/sql/find_user_from_login_hash.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserFromLoginHashRow {
  FindUserFromLoginHashRow(id: Int, username: String, login_hash: BitArray)
}

/// Runs the `find_user_from_login_hash` query
/// defined in `./src/services/users/sql/find_user_from_login_hash.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_user_from_login_hash(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use username <- decode.parameter
      use login_hash <- decode.parameter
      FindUserFromLoginHashRow(
        id: id,
        username: username,
        login_hash: login_hash,
      )
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.bit_array)

  "SELECT * FROM users WHERE login_hash = $1;"
  |> pgo.execute(db, [pgo.bytea(arg_1)], decode.from(decoder, _))
}
