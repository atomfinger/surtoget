import gleam/erlang/process
import gleam/io
import mist
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  let secret_key_base = wisp.random_string(64)
  wisp.configure_logger()

  let assert Ok(_) =
    wisp_mist.handler(fn(_) { todo }, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start()

  process.sleep_forever()
}
