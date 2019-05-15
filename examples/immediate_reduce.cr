require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world
  root_rank = 0
  root_proc = world.process_at(root_rank)
  count = world.size

  if world.rank == root_rank
    future = root_proc.immediate_master_reduce(world.rank, MPI::Operation::SUM)
    sum, _ = future.get
    assert sum == count * (count - 1) // 2
  else
    root_proc.immediate_reduce(world.rank, MPI::Operation::SUM).wait
  end

  future = world.immediate_all_reduce(world.rank, MPI::Operation::MAX)
  max, _ = future.get
  assert max == count - 1
end
