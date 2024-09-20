/// Useful for short circuiting responses with `use <-`
/// 
/// Ex: 
/// use value <- try_unwrap(case get_some_value() {
///   Ok(value) -> Ok(value)
///   _ -> Error(wisp.not_found())
/// })
/// io.debug(value)
/// wisp.ok()
pub fn try_unwrap(result: Result(a, b), continue: fn(a) -> b) -> b {
  case result {
    Ok(value) -> continue(value)
    Error(err_response) -> err_response
  }
}
