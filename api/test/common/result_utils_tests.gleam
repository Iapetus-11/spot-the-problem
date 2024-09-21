import common/result_utils.{try_unwrap}
import gleeunit/should

fn try_unwrap_test_helper(res: Result(String, String)) -> String {
  use x <- try_unwrap(res)
  "success " <> x
}

pub fn try_unwrap_ok_test() {
  should.equal(try_unwrap_test_helper(Ok("OK")), "success OK")
  should.equal(try_unwrap_test_helper(Error("ERROR")), "ERROR")
  should.equal(try_unwrap_test_helper(Error("DEEZ")), "DEEZ")
}
