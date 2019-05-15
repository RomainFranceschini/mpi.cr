require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world
  root_rank = 0
  root_proc = world.process_at(root_rank)

  count = world.size
  i = 2 ** (world.rank + 1)

  if world.rank == root_rank
    future = root_proc.immediate_master_gather(i, count)
    slice, _ = future.get
    puts "Root gathered sequence: #{slice}."

    assert slice.each_with_index(1).all? { |val, i|
      val == 2 ** i
    }
  else
    root_proc.immediate_gather(i).wait
  end

  factor = world.rank + 1
  a = (1..count).map { |x| x*factor }

  if world.rank == root_rank
    future = root_proc.immediate_master_gather(a, count*count)
    slice, _ = future.get
    puts "Root gathered table:"
    slice.each_slice(count, reuse: true) do |chunk|
      puts chunk
    end
    assert (0u64..Float64::INFINITY).each.zip(slice.each).all? { |a, b|
      b == (a // count + 1) * (a % count + 1)
    }
  else
    root_proc.immediate_gather(a).wait
  end
end
