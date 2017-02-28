require "../src/mpi"

MPI.init do |universe|
  world = universe.world

  master_rank = 0
  master_proc = world.process_at(master_rank)

  x = if world.rank == master_rank
        2u64 ** 10u64
      else
        0u64
      end

  x = master_proc.broadcast(x)
  puts "Process #{world.rank} received value: #{x}"
  raise "assertion error" unless x == 1024

  n = 4
  a = if world.rank == master_rank
        (1..n).map { |i| 2u64 ** i.to_u64 }
      else
        Array(UInt64).new(n, 0u64)
      end
  master_proc.broadcast(a)

  puts "Process #{world.rank} received value: #{a}"
  raise "assertion error" unless a == [2u64, 4u64, 8u64, 16u64]
end
