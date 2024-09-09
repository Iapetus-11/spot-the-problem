import api/router
import api/web.{Context}
import dot_env
import dot_env/env
import gleam/erlang/process
import mist
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

  let context = Context(testes: True)

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request(_, context), secret_key)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
