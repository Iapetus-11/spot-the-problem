import common/json_utils.{make_nested_json_object}
import gleam/json
import gleeunit/should

pub fn make_nested_json_object_test() {
  make_nested_json_object([
    #(["test"], json.int(69)),
    #(["user", "id"], json.int(1)),
    #(["user", "public_profile", "name"], json.string("Milo")),
    #(["user", "public_profile", "hobby"], json.string("Programming")),
    #(["user", "created"], json.string("09/01/2000")),
    #(["user", "public_profile", "name"], json.string("Iapetus11")),
  ])
  |> json.to_string()
  |> should.equal(
    "{\"test\":69,\"user\":{\"created\":\"09/01/2000\",\"id\":1,\"public_profile\":{\"hobby\":\"Programming\",\"name\":\"Iapetus11\"}}}",
  )
}
