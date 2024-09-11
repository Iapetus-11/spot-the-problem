import dot_env
import dot_env/env
import gleam/erlang/process
import gleam/pgo
import mist
import router
import web.{Context}
import wisp
import wisp/wisp_mist

// https://gleaming.dev/articles/building-your-first-gleam-web-app/

pub fn main() {
  wisp.configure_logger()

  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load()

  let assert Ok(secret_key) = env.get_string("SECRET_KEY")
  let assert Ok(database_url) = env.get_string("DATABASE_URL")

  let assert Ok(db_config) = pgo.url_config(database_url)
  let db = pgo.connect(pgo.Config(..db_config, pool_size: 2))

  let context = Context(db: db)

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request(_, context), secret_key)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
