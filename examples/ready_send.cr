require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world
  size = world.size
  rank = world.rank

  if rank > 0
    world.barrier
    world.process_at(0).ready_send(rank)
  else
    futures = (1...size).map do |i|
      world.process_at(i).immediate_receive(Int32)
    end
    world.barrier
    values = futures.map { |future| future.get[0] }
    puts "Root got message: #{values}"
    assert values.each.zip((1...size).each).all? { |a, b|
      a == b
    }
  end
end
