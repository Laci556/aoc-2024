import birl
import gleam/float
import gleam/int
import gleam/io

pub fn bechmark(fun: fn() -> a) {
  io.println("⏱️ Measuring...")
  let start = birl.monotonic_now()
  let res = fun()
  io.println(
    "⏱️ Took "
    <> float.to_string(int.to_float(birl.monotonic_now() - start) /. 1000.0)
    <> "ms",
  )
  res
}
