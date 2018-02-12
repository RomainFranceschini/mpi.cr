require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world

  x = Math::PI
  y = 0.0

  sreq = world.this_process.immediate_send(x)
  rreq = world.any_process.immediate_receive(pointerof(y), 1)
  rreq.wait

  loop do
    if status = sreq.status
      break
    end
  end

  assert x == y

  y = 0.0
  rreq = world.any_process.immediate_receive(pointerof(y), 1)
  sreq = world.this_process.immediate_send(x)

  assert x == y

  assert world.any_process.immediate_probe == nil
  assert world.any_process.immediate_matched_probe == nil

  y = 0.0
  sreq = world.this_process.immediate_synchronous_send(x)
  if preq = world.any_process.immediate_matched_probe
    msg, _ = preq
    rreq = msg.immediate_matched_receive(pointerof(y), 1)
    assert x == y
  else
    raise "immediate matched probe should not be nil"
  end

  future = world.any_process.immediate_receive(Float64)
  world.this_process.send(x)
  y, _ = future.get

  assert x == y
end
