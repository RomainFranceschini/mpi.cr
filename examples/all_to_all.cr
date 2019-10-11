require "../spec/examples_helper"

MPI.init do |universe|
  world = universe.world
  rank = world.rank
  size = world.size

  u = Slice.new(size, rank)
  v = world.all_to_all(u) # , size)

  pp u
  pp v

  assert v.each.zip((0...size).each).all? { |i, j| i == j }
end
