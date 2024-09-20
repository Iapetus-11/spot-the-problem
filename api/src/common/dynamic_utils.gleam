import common/json_utils
import gleam/dynamic.{type DecodeError}
import gleam/json
import gleam/list

pub fn encode_errors_to_json_string(errors: List(DecodeError)) -> json.Json {
  list.map(errors, fn(err) {
    #(
      err.path,
      json.string(
        "Expected " <> err.expected <> " but found " <> err.found <> " instead.",
      ),
    )
  })
  |> json_utils.make_nested_json_object()
}
