require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world

  x = Math::PI
  y = 0.0

  sreq = world.this_process.immediate_send(pointerof(x), 1)
  rreq = world.any_process.immediate_receive(pointerof(y), 1)
  rreq.wait
  loop do
    break if sreq.completed?
  end
  assert x == y

  y = 0.0
  rreq = world.any_process.immediate_receive(pointerof(y), 1)
  sreq = world.this_process.immediate_ready_send(x)
  rreq.wait
  sreq.wait
  assert x == y

  assert world.any_process.immediate_probe == nil
  assert world.any_process.immediate_matched_probe == nil

  y = 0.0
  sreq = world.this_process.immediate_synchronous_send(pointerof(x), 1)
  if preq = world.any_process.immediate_matched_probe
    msg, _ = preq
    rreq = msg.immediate_matched_receive(pointerof(y), 1)
    sreq.wait
    rreq.wait
  else
    raise "immediate matched probe should not be nil"
  end
  assert x == y

  future = world.any_process.immediate_receive(Float64)
  world.this_process.send(x)
  y, _ = future.get
  assert x == y

  future = world.any_process.immediate_receive(Float64)
  assert future.try == nil
  world.this_process.send(x)
  loop do
    if tuple = future.try
      msg, _ = tuple
      assert x == msg
      break
    end
  end

  sreq = world.this_process.immediate_send(x)
  sreq.cancel
  sreq.wait
end
