import gleam/dict
import gleam/json
import gleam/list

pub type NestedObjectOrValue {
  NestedValue(json.Json)
  NestedObject(dict.Dict(String, NestedObjectOrValue))
}

pub fn paths_to_nested(
  paths: List(String),
  cum: dict.Dict(String, NestedObjectOrValue),
  value: json.Json,
) -> dict.Dict(String, NestedObjectOrValue) {
  case paths {
    [] -> cum
    [key] -> dict.insert(cum, key, NestedValue(value))
    [key, ..paths] -> {
      let new_cum = case dict.get(cum, key) {
        Ok(NestedObject(nc)) -> nc
        _ -> dict.new()
      }

      dict.insert(
        cum,
        key,
        NestedObject(paths_to_nested(paths, new_cum, value)),
      )
    }
  }
}

fn nested_to_json(nested: NestedObjectOrValue) -> json.Json {
  case nested {
    NestedValue(j) -> j
    NestedObject(obj) -> {
      dict.to_list(obj)
      |> list.map(fn(key_and_value) {
        #(key_and_value.0, nested_to_json(key_and_value.1))
      })
      |> json.object
    }
  }
}

pub fn make_nested_json_object(
  items: List(#(List(String), json.Json)),
) -> json.Json {
  let obj =
    list.fold(items, dict.new(), fn(cum, item) {
      paths_to_nested(item.0, cum, item.1)
    })
  nested_to_json(NestedObject(obj))
}
