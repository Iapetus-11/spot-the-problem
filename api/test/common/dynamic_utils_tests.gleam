import common/dynamic_utils.{encode_errors_to_json}
import gleam/dict
import gleam/dynamic
import gleam/json
import gleeunit/should

type TestHelperNestedType {
  TestHelperNestedType(d_bool: Bool)
}

type TestHelperType {
  TestHelperType(a_string: String, b_int: Int, c_nested: TestHelperNestedType)
}

fn decode_test_helper_type(thing: dynamic.Dynamic) {
  dynamic.decode3(
    TestHelperType,
    dynamic.field("a_string", of: dynamic.string),
    dynamic.field("b_int", of: dynamic.int),
    dynamic.field(
      "c_nested",
      of: dynamic.decode1(
        TestHelperNestedType,
        dynamic.field("d_bool", of: dynamic.bool),
      ),
    ),
  )(thing)
}

pub fn encode_errors_to_json_empty_object_test() {
  let decode_errors =
    should.be_error(decode_test_helper_type(dynamic.from(dict.new())))

  encode_errors_to_json(decode_errors)
  |> json.to_string()
  |> should.equal(
    "{\"a_string\":\"Expected field but found nothing instead.\","
    <> "\"b_int\":\"Expected field but found nothing instead.\","
    <> "\"c_nested\":\"Expected field but found nothing instead.\"}",
  )
}

pub fn encode_errors_to_json_incorrect_field_type_test() {
  let decode_errors =
    should.be_error(
      decode_test_helper_type(
        dynamic.from(
          dict.from_list([
            #("a_string", dynamic.from("Test")),
            #("b_int", dynamic.from(123)),
            #("c_nested", dynamic.from("A String")),
          ]),
        ),
      ),
    )

  encode_errors_to_json(decode_errors)
  |> json.to_string()
  |> should.equal("{\"c_nested\":\"Expected Dict but found String instead.\"}")
}

pub fn encode_errors_to_json_missing_nested_field_test() {
  let decode_errors =
    should.be_error(
      decode_test_helper_type(
        dynamic.from(
          dict.from_list([
            #("a_string", dynamic.from("Test")),
            #("b_int", dynamic.from(123)),
            #("c_nested", dynamic.from(dict.new())),
          ]),
        ),
      ),
    )

  encode_errors_to_json(decode_errors)
  |> json.to_string()
  |> should.equal(
    "{\"c_nested\":{\"d_bool\":\"Expected field but found nothing instead.\"}}",
  )
}
