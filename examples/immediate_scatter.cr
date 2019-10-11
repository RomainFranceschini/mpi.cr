require "../spec/examples_helper"

MPI.init do |universe|
  world = universe.world
  root_rank = 0
  root_proc = world.process_at(root_rank)
  size = world.size
  rank = world.rank

  x = if rank == root_rank
        a = (0...size).to_a
        root_proc.immediate_master_scatter(a).get[0]
      else
        root_proc.immediate_scatter(Int32).get[0]
      end

  assert x == rank
end
