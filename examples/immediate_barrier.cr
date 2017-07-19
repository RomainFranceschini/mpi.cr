require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world

  if world.rank == 0
    n = world.size - 1
    slice = Slice(UInt64).new(3*n, 0u64)

    # receive first 2*n messages
    (0...2*n).each { |i|
      world.any_process.receive(slice[i, 1])
    }

    # signal waiting senders that 2*n messages have been received
    breq = world.immediate_barrier

    # receive remaining n messages
    (2*n...n*3).each { |i|
      world.any_process.receive(slice[i, 1])
    }

    puts slice

    # messages "1" and "2" may be interleaved, but all have to be contained
    # within the first  2 * n slots of the buffer
    assert slice[0, 2*n].select { |x| x == 1 }.size == n
    assert slice[0, 2*n].select { |x| x == 2 }.size == n

    # the last n slots in the buffer may only contain message "3"
    assert slice[2*n, n].all? { |x| x == 3 }

    # clean up barrier request
    breq.wait
  else
    world.process_at(0).send(1u64)
    # join barrier, but do not block
    breq = world.immediate_barrier
    world.process_at(0).send(2u64)
    # wait for receiver process to receive the first 2 * n messages
    breq.wait
    world.process_at(0).send(3u64)
  end
end
