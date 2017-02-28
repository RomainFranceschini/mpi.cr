require "../src/mpi"

MPI.init do |universe|
  world = universe.world

  if world.rank == 0
    n = world.size - 1
    slice = Slice(UInt64).new(2*n, 0u64)

    (0...n).each { |i|
      world.any_process.receive(slice[i, 1])
    }

    world.barrier

    (n...n*2).each { |i|
      world.any_process.receive(slice[i, 1])
    }

    puts slice

    raise "assertion error" unless slice[0, n].all? { |x| x == 1u64 }
    raise "assertion error" unless slice[n, n].all? { |x| x == 2u64 }
  else
    world.process_at(0).send(1u64)
    world.barrier
    world.process_at(0).send(2u64)
  end
end
