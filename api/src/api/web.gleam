import gleam/dict.{type Dict}
import gleam/pgo
import services/problem_sets/problem_sets.{type ProblemSet}

pub type Context {
  Context(db: pgo.Connection, problem_sets: Dict(String, ProblemSet))
}
