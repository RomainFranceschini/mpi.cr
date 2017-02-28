require "../src/mpi"

MPI.init do |universe|
  world = universe.world

  rank = world.rank
  size = world.size
  master_rank = 0
  master_proc = world.process_at(master_rank)

  x = 0
  if rank == master_rank
    ary = (0...size).to_a
    puts "Master process #{master_rank} scatters #{ary}"
    x = master_proc.master_scatter(ary)
  else
    x = master_proc.scatter(Int32)
  end

  puts "Process #{rank} received #{x}"
  raise "assertion error" unless x == rank
end
