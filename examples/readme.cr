require "../spec/examples_helper"

MPI.init do |universe|
  world = universe.world
  size = world.size
  rank = world.rank

  next_rank = (rank + 1) % size
  next_proc = world.process_at(next_rank)
  prev_rank = (rank - 1) % size

  msg = [rank, 2*rank, 4*rank]
  sreq = next_proc.immediate_send(msg)

  msg, status = world.any_process.receive_array(Int32)
  puts "Process #{rank} got message: #{msg}, status: #{status}."

  x = status.source_rank
  assert x == prev_rank
  assert [x, 2*x, 4*x] == msg

  root_rank = 0
  root_proc = world.process_at(root_rank)

  a = if world.rank == root_rank
        [2, 4, 8, 16].tap { |a| puts "Root broadcasting value: #{a}." }
      else
        Array.new(4) { 0 }
      end

  root_proc.broadcast(a)
  puts "Rank #{rank} received value: #{a}."
  assert a == [2, 4, 8, 16]
end
