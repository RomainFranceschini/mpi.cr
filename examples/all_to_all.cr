require "../src/mpi"

MPI.init do |universe|
  world = universe.world
  rank = world.rank
  size = world.size

  u = Slice.new(size, rank)
  v = world.all_to_all(u, size)

  pp u
  pp v
end
