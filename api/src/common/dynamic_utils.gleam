import gleam/dynamic.{type DecodeError}
import gleam/json
import gleam/list
import gleam/string
import gleam/string_builder.{type StringBuilder}

pub fn encode_errors_to_json_string(errors: List(DecodeError)) -> StringBuilder {
  let json_errors: json.Json =
    json.array(errors, fn(err: DecodeError) -> json.Json {
      json.string(
        string.join(list.map(err.path, string.inspect(_)), ".")
        <> ": Expected "
        <> err.expected
        <> " but found "
        <> err.found
        <> " instead",
      )
    })

  json.to_string_builder(json_errors)
}
