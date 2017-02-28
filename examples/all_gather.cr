require "../src/mpi"

MPI.init do |universe|
  world = universe.world
  master_rank = 0
  count = world.size

  i = 2u64 ** (world.rank.to_u64 + 1u64)
  slice = world.all_gather(i, world.size)

  if world.rank == master_rank
    puts "Master gathered sequence: #{slice}"
  end

  tmp = 0u64
  raise "assertion error" unless slice.all? { |x| tmp += 1u64; x == 2u64**tmp }

  factor = world.rank.to_u64 + 1u64
  a = (1u64..count.to_u64).map { |x| x * factor }
  slice = world.all_gather(a, count*count)

  if world.rank == master_rank
    puts "Master gathered table:"
    slice.each_slice(count, reuse: true) do |chunk|
      puts chunk
    end
  end
end
