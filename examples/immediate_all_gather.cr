require "../spec/examples_helper"

# TODO check why status count returns 0 with collective operations

MPI.init do |universe|
  world = universe.world
  master_rank = 0
  master_proc = world.process_at(master_rank)
  count = world.size

  i = 2 ** (world.rank + 1)
  slice, status = world.immediate_all_gather(i, count).get

  # puts "Process #{world.rank} received #{status.count(Int32)} elements from #{status.source_rank}."
  if world.rank == master_rank
    puts "Root gathered sequence: #{slice}"
  end

  str = "ab"
  gathered_string, status = world.immediate_all_gather(str, count * str.size).get

  # puts "Process #{world.rank} received #{status.count(UInt8)} elements from #{status.source_rank}."
  if world.rank == master_rank
    puts "Root gathered string: #{gathered_string}"
  end

  factor = world.rank + 1
  to_send = (1..count).map { |x| x*factor }

  future = world.immediate_all_gather(to_send, to_send.size * count)
  slice, _ = future.get

  if world.rank == master_rank
    puts "Root gathered table:"
    slice.each_slice(count, reuse: true) do |chunk|
      puts chunk
    end
  end

  assert (0u64..Float64::INFINITY).each.zip(slice.each).all? { |a, b|
    b == (a // count + 1) * (a % count + 1)
  }
end
