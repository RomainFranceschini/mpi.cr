require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world
  size = world.size

  raise "This example requires at least two processes." if size < 2

  rank = world.rank

  next_rank = rank + 1 < size ? rank + 1 : 0
  next_proc = world.process_at(next_rank)
  prev_rank = rank - 1 >= 0 ? rank - 1 : size - 1
  prev_proc = world.process_at(prev_rank)

  msg, status = MPI.send_receive(rank, prev_proc, next_proc)
  puts "Process #{rank} got message '#{msg}'. Status is: #{status}"
  world.barrier
  assert msg == next_rank

  if rank > 0
    world.process_at(0).send([rank, rank + 1, rank - 1])
  else
    (size-1).times do
      ary, status = world.any_process.receive_array(Int32)
      puts "Process #{rank} got message '#{ary}'. Status is: #{status}"

      x = status.source_rank
      ary2 = [x, x+1, x-1]

      assert ary == ary2
    end
  end

  world.barrier

  x = rank
  MPI.send_receive_replace(pointerof(x), 1, next_proc, prev_proc)
  assert x == prev_rank
end
