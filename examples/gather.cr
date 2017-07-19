require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world

  master_rank = 0
  master_proc = world.process_at(master_rank)

  count = world.size
  i = ((world.rank + 1) ** 2).to_u64

  if world.rank == master_rank
    slice = Slice(UInt64).new(count, 0u64)
    master_proc.master_gather(pointerof(i), 1, slice.to_unsafe, count)
    puts "Master process gathered sequence: #{slice}"
  else
    master_proc.gather(i)
  end

  factor = (world.rank + 1).to_u64
  a = (1u64..count).map { |x| x*factor }

  if world.rank == master_rank
    slice = master_proc.master_gather(a, count*count)
    puts "Master process gathered table:"
    slice.each_slice(count, reuse: true) do |chunk|
      puts chunk
    end
  else
    master_proc.gather(a)
  end
end
