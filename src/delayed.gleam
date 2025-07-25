//// The purpose of this file is to hold data related to whether there are any current
//// delays for Sørlandsbanen. We update only once every 5 minutes to avoid hitting the
//// entur API any more than we need to.
//// 
//// Right now we will only hold a boolean, but in the future we might hold more data.

import entur_client
import gleam/erlang/process
import gleam/otp/actor

// 5 minutes in ms
const wait_time_ms = 300_000

// Starts a very simple scheduled process that kics inn every 5 minutes
pub fn start() -> Result(
  actor.Started(process.Subject(DelayMessage)),
  actor.StartError,
) {
  let start_result =
    actor.new(State(False))
    |> actor.on_message(handle_message)
    |> actor.start()
  case start_result {
    Ok(result) -> {
      process.spawn(fn() { scheduler(result.data) })
      start_result
    }
    Error(_) -> start_result
  }
}

pub fn is_delayed(subject: process.Subject(DelayMessage)) -> Bool {
  process.call(subject, 100, fn(reply_to) { GetState(reply_to) })
}

fn scheduler(subject: process.Subject(DelayMessage)) {
  update(subject)
  process.sleep(wait_time_ms)
  scheduler(subject)
}

fn update(subject: process.Subject(DelayMessage)) {
  let has_delays = entur_client.is_train_delayed()
  process.send(subject, SetState(State(has_delays)))
}

pub type State {
  State(has_delay: Bool)
}

pub type DelayMessage {
  SetState(State)
  GetState(process.Subject(Bool))
}

fn handle_message(state: State, message: DelayMessage) {
  case message {
    SetState(state) -> actor.continue(state)
    GetState(reply_to) -> {
      process.send(reply_to, state.has_delay)
      actor.continue(state)
    }
  }
}
