require "../spec/examples_helper"

def fac(n)
  (1..n).reduce(1) { |acc, x| acc * x }
end

MPI.init do |universe|
  world = universe.world
  rank = world.rank

  x, _ = world.immediate_scan(rank, MPI::Operation::SUM).get
  assert x == (rank * (rank + 1)) // 2

  y = rank + 1
  z, _ = world.immediate_exclusive_scan(y, MPI::Operation::PROD).get
  if rank > 0
    assert z == fac(y - 1)
  end
end
