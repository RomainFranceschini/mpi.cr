# TODO
require "../spec/spec_helper"

def fac(n)
  (1..n).reduce(1) { |acc, x| acc * x }
end

MPI.init do |universe|
  world = universe.world
  rank = world.rank

  x = world.scan(rank, MPI::Operation::SUM)
  assert x == (rank * (rank + 1)) // 2

  y = rank + 1
  z = world.exclusive_scan(y, MPI::Operation::PROD)
  if rank > 0
    assert z == fac(y - 1)
  end
end
