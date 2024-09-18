import gleam/json
import gleam/list
import gleam/string
import wisp.{type Request, type Response}

pub fn require_header_value(
  req: Request,
  header: String,
  status_if_missing: Int,
  continue: fn(String) -> _,
) -> Response {
  let header = string.capitalise(header)

  case
    list.find_map(req.headers, fn(key_and_value) {
      let #(key, value) = key_and_value
      case string.capitalise(key) {
        key if key == header -> Ok(value)
        _ -> Error("No '" <> header <> "' header")
      }
    })
  {
    Ok(value) -> continue(value)
    _ ->
      json.object([
        #(
          "headers",
          json.object([
            #(
              header,
              json.array(["Expected value but found nothing."], json.string(_)),
            ),
          ]),
        ),
      ])
      |> json.to_string_builder()
      |> wisp.json_response(status_if_missing)
  }
}
